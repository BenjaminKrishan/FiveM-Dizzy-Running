local playerInRace = {}
local lastRaceTime = 0

assert(Config.Goals and #Config.Goals > 0, "❌ Config.Goals must be set in config.lua!")

local function isValidLocation(propCoords)
    if not Config.Locations or #Config.Locations == 0 then return true end
    
    for _, loc in ipairs(Config.Locations) do
        if loc.coords and #(loc.coords - propCoords) < Config.MaxInteractDistance then
            return true
        end
    end
    return false
end

local function isNearProp(source, propCoords)
    local playerPed = GetPlayerPed(source)
    if not playerPed or playerPed == 0 then return false end
    
    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(playerCoords - propCoords)
    return distance <= (Config.MaxInteractDistance + 2.0)
end

lib.callback.register('dizzy_running:server:canStartRace', function(source, propCoords)
    if playerInRace[source] then
        return false, 'already_in_race'
    end

    if not isNearProp(source, propCoords) then
        return false, 'too_far'
    end

    if Config.GlobalCooldown and Config.GlobalCooldown > 0 then
        local currentTime = os.time() * 1000
        local timeSinceLastRace = currentTime - lastRaceTime
        if timeSinceLastRace < Config.GlobalCooldown then
            local remainingSecs = math.ceil((Config.GlobalCooldown - timeSinceLastRace) / 1000)
            return false, 'global_cooldown', remainingSecs
        end
    end

    if not isValidLocation(propCoords) then
        return false, 'invalid_location'
    end

    if Config.Requirements.enabled then
        local count = exports.ox_inventory:GetItemCount(source, Config.Requirements.item)
        if count < Config.Requirements.count then
            return false, 'no_item'
        end
    end

    return true
end)

RegisterNetEvent('dizzy_running:server:startRace', function()
    local src = source
    
    if Config.Requirements.enabled then
        local count = exports.ox_inventory:GetItemCount(src, Config.Requirements.item)
        if count >= Config.Requirements.count then
            exports.ox_inventory:RemoveItem(src, Config.Requirements.item, Config.Requirements.count)
        else
            return
        end
    end

    local randomIdx = math.random(1, #Config.Goals)
    playerInRace[src] = { goalIndex = randomIdx }
    
    TriggerClientEvent('dizzy_running:client:setGoal', src, randomIdx)
end)

RegisterNetEvent('dizzy_running:server:finishRace', function(reachedGoal)
    local src = source
    local raceData = playerInRace[src]
    if not raceData then return end
    
    if reachedGoal then
        local goal = Config.Goals[raceData.goalIndex]
        local playerPed = GetPlayerPed(src)
        if playerPed and playerPed ~= 0 and goal then
            local playerCoords = GetEntityCoords(playerPed)
            if #(playerCoords - goal.coords) > (goal.radius + 5.0) then
                reachedGoal = false
            end
        else
            reachedGoal = false
        end
    end

    if reachedGoal and Config.Rewards.enabled then
        exports.ox_inventory:AddItem(src, Config.Rewards.item, Config.Rewards.count)
        TriggerClientEvent('ox_lib:notify', src, {
            title = Config.Notify.ReceivedReward.title,
            description = string.format(Config.Notify.ReceivedReward.description, Config.Rewards.count, Config.Rewards.label or Config.Rewards.item),
            type = Config.Notify.ReceivedReward.type
        })
    end

    playerInRace[src] = nil
    lastRaceTime = os.time() * 1000
end)

AddEventHandler('playerDropped', function()
    local src = source
    playerInRace[src] = nil
end)
