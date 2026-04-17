assert(Config.Goals and #Config.Goals > 0, "❌ Config.Goals must be set in config.lua!")

local isSpinning = false
local currentRaceState = nil
local raceCooldown = false
local monitorActive = false
local controlsInverted = false
local selectedGoalIndex = 1
local spinCam = nil

RegisterNetEvent('dizzy_running:client:setGoal', function(goalIndex)
    selectedGoalIndex = goalIndex
end)

local function clearAllEffects(ped)
    if not ped then ped = PlayerPedId() end
    
    ClearPedTasksImmediately(ped)
    StopAnimTask(ped, "WORLD_HUMAN_BUM_SLACKER", "WORLD_HUMAN_BUM_SLACKER", 1.0)
    FreezeEntityPosition(ped, false)
    SetEntityRotation(ped, 0.0, 0.0, GetEntityHeading(ped), 2, true)

    ResetPedMovementClipset(ped, 0.0)
    ClearTimecycleModifier()
    StopGameplayCamShaking(true)
    SetPedMotionBlur(ped, false)
    StopScreenEffect("Drunk")

    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    
    if spinCam then
        DestroyCam(spinCam, false)
        RenderScriptCams(false, true, 500, true, true)
        spinCam = nil
    end


    currentRaceState = nil
    isSpinning = false
    monitorActive = false
    controlsInverted = false
end

local function resetPlayerEffects(ped, reachedGoal)
    clearAllEffects(ped)
    
    raceCooldown = true
    SetTimeout(3000, function() raceCooldown = false end)

    TriggerServerEvent('dizzy_running:server:finishRace', reachedGoal)
end

local function startSpinning(ped, propCoords)
    CreateThread(function()
        local heading = GetEntityHeading(ped)
        
        spinCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        local camOffset = vector3(2.5, 2.5, 2.0)
        SetCamCoord(spinCam, propCoords.x + camOffset.x, propCoords.y + camOffset.y, propCoords.z + camOffset.z)
        PointCamAtCoord(spinCam, propCoords.x, propCoords.y, propCoords.z + 1.0)
        SetCamActive(spinCam, true)
        RenderScriptCams(true, true, 500, true, true)

        local anim = Config.SpinAnimation
        lib.requestAnimDict(anim.dict)
        TaskPlayAnim(ped, anim.dict, anim.anim, 8.0, 8.0, -1, 1, 0, false, false, false)
        
        while isSpinning do
            local angle = (heading - 90) * (math.pi / 180)
            local radius = Config.SpinRadius or 0.2
            local offset = vector3(math.cos(angle) * radius, math.sin(angle) * radius, 0.0)
            local targetCoords = propCoords + offset
            
            local _, groundZ = GetGroundZFor_3dCoord(targetCoords.x, targetCoords.y, targetCoords.z + 2.0, false)
            
            SetEntityCoordsNoOffset(ped, targetCoords.x, targetCoords.y, (groundZ or targetCoords.z) + 1.2, false, false, false)
            SetEntityRotation(ped, 20.0, 0.0, (heading + 180) % 360, 2, true)

            if not IsEntityPlayingAnim(ped, anim.dict, anim.anim, 3) then
                TaskPlayAnim(ped, anim.dict, anim.anim, 8.0, 8.0, -1, 1, 0, false, false, false)
            end

            heading = heading + Config.SpinSpeed
            Wait(10)
        end

        if DoesCamExist(spinCam) then
            DestroyCam(spinCam, false)
            RenderScriptCams(false, true, 500, true, true)
            spinCam = nil
        end
    end)
end

local function monitorGoal(ped)
    if monitorActive then return end 
    monitorActive = true
    
    CreateThread(function()
        local startTime = GetGameTimer()
        local lastEffectTime = 0
        local goal = Config.Goals[selectedGoalIndex]
        
        while monitorActive and currentRaceState == 'dizzy' do
            local coords = GetEntityCoords(ped)
            
            if goal and #(coords - goal.coords) < goal.radius then
                resetPlayerEffects(ped, true)
                lib.notify(Config.Notify.End)
                break
            end

            if Config.HardMode.enabled then
                local currentTime = GetGameTimer()
                
                if IsPedOnFoot(ped) and GetEntitySpeed(ped) > 0.5 then
                    local currentHeading = GetEntityHeading(ped)

                    local drift = (math.random() - 0.5) * Config.HardMode.staggerStrength
                    SetEntityHeading(ped, currentHeading + drift)
                end

                if (currentTime - lastEffectTime) > 1000 then

                    if math.random() < Config.HardMode.blackoutChance then
                        DoScreenFadeOut(100)
                        Wait(200)
                        DoScreenFadeIn(200)
                    end

                    if Config.HardMode.controlInversion and math.random() < Config.HardMode.inversionChance then
                        controlsInverted = not controlsInverted
                        if controlsInverted then
                            lib.notify({title = 'අවධානය!', description = 'ඔබේ පාලනයන් උඩුයටිකුරු විය!', type = 'warning'})
                        else
                            lib.notify({title = 'අවධානය!', description = 'පාලනයන් නැවත යථා තත්ත්වයට පත් විය.', type = 'inform'})
                        end
                    end

                    if math.random() < Config.HardMode.tripChance and GetEntitySpeed(ped) > 3.0 then
                        SetPedToRagdoll(ped, 1500, 2000, 0, 0, 0, 0)
                        lib.notify({title = 'අපොයි!', description = 'ඔබට සමබරතාවය නැති විය!', type = 'error'})
                    end

                    lastEffectTime = GetGameTimer()
                end
            end

            if GetGameTimer() - startTime > Config.DizzyDuration then
                resetPlayerEffects(ped, false)
                lib.notify(Config.Notify.TimeUp)
                break
            end
            Wait(100)
        end
        monitorActive = false
    end)
end

local function startDizzyRace(propCoords)
    if isSpinning or currentRaceState or raceCooldown then return end

    local canStart, reason, extra = lib.callback.await('dizzy_running:server:canStartRace', false, propCoords)

    if not canStart then
        if reason == 'already_in_race' then
            lib.notify(Config.Notify.AlreadyInRace)
        elseif reason == 'too_far' then
            lib.notify(Config.Notify.TooFar)
        elseif reason == 'global_cooldown' then
            lib.notify({
                title = Config.Notify.GlobalCooldown.title,
                description = string.format(Config.Notify.GlobalCooldown.description, extra or "?"),
                type = Config.Notify.GlobalCooldown.type
            })
        elseif reason == 'no_item' then
            lib.notify({
                title = Config.Notify.NoItem.title,
                description = string.format(Config.Notify.NoItem.description, (Config.Requirements.count or 1) .. 'x ' .. (Config.Requirements.label or Config.Requirements.item)),
                type = Config.Notify.NoItem.type
            })
        else
            lib.notify(Config.Notify.TooFar)
        end
        return
    end

    TriggerServerEvent('dizzy_running:server:startRace')

    local ped = PlayerPedId()
    isSpinning = true
    currentRaceState = 'spinning'

    lib.notify(Config.Notify.Start)

    startSpinning(ped, propCoords)

    local success = lib.progressBar({
        duration = Config.SpinDuration,
        label = 'පොල්ල වටේ කැරකෙමින් පවතී...',
        useWhileDead = false,
        canCancel = true,
        cancelText = 'කැරකීම නවත්වන්න',
        disable = { move = true, car = true, mouse = false, combat = true }
    })

    if not success then
        isSpinning = false
        resetPlayerEffects(ped, false)
        return
    end

    local wasSpinning = isSpinning
    isSpinning = false
    
    if wasSpinning then
        if spinCam then
            DestroyCam(spinCam, false)
            RenderScriptCams(false, true, 500, true, true)
            spinCam = nil
        end
        
        FreezeEntityPosition(ped, false)
        ClearPedTasksImmediately(ped)
        currentRaceState = 'dizzy'
        lib.notify(Config.Notify.Dizzy)

        ShakeGameplayCam('DRUNK_SHAKE', 3.5)
        SetTimecycleModifier("Drunk")
        SetPedMotionBlur(ped, true)
        StartScreenEffect("Drunk", 0, true)
        
        RequestAnimSet(Config.DizzyMovementClipset)
        while not HasAnimSetLoaded(Config.DizzyMovementClipset) do Wait(0) end
        
        SetPedMovementClipset(ped, Config.DizzyMovementClipset, 1.0)
        SetRunSprintMultiplierForPlayer(PlayerId(), Config.DizzyRunMultiplier)

        monitorGoal(ped)
    else
        resetPlayerEffects(ped, false)
    end
end

local spawnedProps = {}
local function spawnProps()
    if not Config.Locations or #Config.Locations == 0 then return end
    
    local targetOptions = {
        {
            name = 'start_dizzy_race',
            onSelect = function(data)
                startDizzyRace(GetEntityCoords(data.entity))
            end,
            icon = 'fas fa-spinner',
            label = 'තරඟය ආරම්භ කරන්න',
            canInteract = function()
                return currentRaceState == nil and not raceCooldown
            end
        }
    }

    for i, loc in ipairs(Config.Locations) do
        local model = loc.prop or Config.PropModel
        lib.requestModel(model)

        local prop = CreateObject(model, loc.coords.x, loc.coords.y, loc.coords.z - 1.0, false, false, false)
        PlaceObjectOnGroundProperly(prop)
        FreezeEntityPosition(prop, true)
        
        exports.ox_target:addLocalEntity(prop, targetOptions)
        
        table.insert(spawnedProps, prop)
    end
end

CreateThread(function()
    spawnProps()
end)

CreateThread(function()
    while true do
        if currentRaceState == 'dizzy' and Config.HardMode.enabled and Config.HardMode.controlInversion then
            if controlsInverted then
                DisableControlAction(0, 34, true)
                DisableControlAction(0, 35, true) 
                
                if IsDisabledControlPressed(0, 34) then
                    SetControlNormal(0, 35, 1.0)
                elseif IsDisabledControlPressed(0, 35) then
                    SetControlNormal(0, 34, 1.0)
                end
            end
            Wait(0)
        else
            Wait(500)
        end
    end
end)

CreateThread(function()
    while true do
        local wait = 1000
        local ped = PlayerPedId()
        local isRacing = currentRaceState ~= nil

        if (isRacing and Config.Marker.enabled) or (currentRaceState == 'dizzy' and Config.Goals and Config.Goals[selectedGoalIndex]) then
            wait = 0
            
            if isRacing and Config.Marker.enabled then
                local coords = GetEntityCoords(ped)
                DrawMarker(
                    Config.Marker.type,
                    coords.x, coords.y, coords.z + Config.Marker.heightOffset,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    Config.Marker.scale.x, Config.Marker.scale.y, Config.Marker.scale.z,
                    Config.Marker.color.r, Config.Marker.color.g, Config.Marker.color.b, Config.Marker.color.a,
                    false, true, 2, nil, nil, false
                )
            end

            if currentRaceState == 'dizzy' then
                local g = Config.Goals[selectedGoalIndex]
                if g and g.marker.enabled then
                    local gm = g.marker
                    DrawMarker(
                        gm.type,
                        g.coords.x, g.coords.y, g.coords.z - 1.0,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        gm.scale.x, gm.scale.y, gm.scale.z,
                        gm.color.r, gm.color.g, gm.color.b, gm.color.a,
                        false, true, 2, nil, nil, false
                    )
                end
            end
        end

        Wait(wait)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    for _, prop in ipairs(spawnedProps) do
        if DoesEntityExist(prop) then
            DeleteObject(prop)
        end
    end

    clearAllEffects()
end)

RegisterNetEvent('qbx_core:client:onPlayerUnload', function()
    clearAllEffects()
end)

CreateThread(function()
    while true do
        if currentRaceState ~= nil then
            if Config.HardMode.enabled and Config.HardMode.disableJump then
                DisableControlAction(0, 22, true)
            end
            Wait(0)
        else
            Wait(500)
        end
    end
end)