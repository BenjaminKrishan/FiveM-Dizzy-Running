Config = {}

-- General Race Settings
Config.PropModel = "pani_babare"
Config.SpinDuration = 10000 -- 10 seconds
Config.DizzyDuration = 30000 -- 15 seconds
Config.SpinSpeed = 15.0
Config.DizzyMovementClipset = "move_m@drunk@verydrunk"
Config.DizzyRunMultiplier = 0.8
Config.MaxInteractDistance = 3.0
Config.CancelDistance = 5.0 -- Cancel if player moves this far during spinning
Config.GlobalCooldown = 60000 -- Global cooldown between races in milliseconds (e.g., 60s)
Config.SpinRadius = 0.35 -- Distance for bending down to the pole
Config.SpinAnimation = {
    type = "anim",
    dict = "amb@medic@standing@tendtodead@base",
    anim = "base"
}
-- UI Marker Settings (Player)
Config.Marker = {
    enabled = true,
    type = 0, -- Upside down triangle
    color = { r = 255, g = 215, b = 0, a = 200 }, -- Golden yellow
    heightOffset = 1.2,
    scale = vec3(0.5, 0.5, 0.5)
}

-- Race Goal / End Point (Multiple random goals supported)
Config.Goals = {
    {
        coords = vec3(-1139.22, 148.04, 62.82),
        radius = 2.5,
        marker = {
            enabled = true,
            type = 1, -- Vertical cylinder
            color = { r = 0, g = 255, b = 0, a = 120 }, -- Semi-transparent Green
            scale = vec3(3.0, 3.0, 1.0)
        }
    },
    {
        coords = vec3(-1147.78, 140.63, 62.21), -- Random point 2
        radius = 2.5,
        marker = {
            enabled = true,
            type = 1,
            color = { r = 0, g = 255, b = 0, a = 120 },
            scale = vec3(3.0, 3.0, 1.0)
        }
    },
    {
        coords = vec3(-1163.05, 129.56, 60.93), -- Random point 3
        radius = 2.5,
        marker = {
            enabled = true,
            type = 1,
            color = { r = 0, g = 255, b = 0, a = 120 },
            scale = vec3(3.0, 3.0, 1.0)
        }
    },
}

-- Specific Locations (Race Start Points)
Config.Locations = {
    { 
        coords = vec3(-1156.13, 159.92, 63.33),
        prop = "pani_babare" -- Optional: Override the default Config.PropModel for this location
    },
}

-- Item Requirements & Rewards
Config.Requirements = {
    enabled = true,
    item = "game_enter",
    count = 1,
    label = "අවුරුදු ක්‍රීඩා ඇතුළත් වීමේ පත්‍රිකාව"
}

Config.Rewards = {
    enabled = true,
    item = "game_voucher",
    count = 1,
    label = "ජයග්‍රාහී වොවුචරය"
}

-- Difficulty Hardening (Advanced Dizzy Effects)
Config.HardMode = {
    enabled = true,
    staggerStrength = 2.0, -- How much the player veers off course
    blackoutChance = 0.2, -- Chance of a momentary blackout every second
    controlInversion = true, -- Randomly swap A/D controls
    inversionChance = 0.15, -- Chance per second to swap state
    tripChance = 0.05, -- Chance to trip/ragdoll while running
    disableJump = true, -- Disable jumping during the race (only when HardMode is active)
}

Config.Notify = {
    Start = {
        title = 'සිංහල අවුරුදු උත්සවය',
        description = 'කැරකීම ආරම්භ විය! ඔළුව කෙළින් තබාගන්න.',
        type = 'inform',
        position = 'top'
    },
    Dizzy = {
        title = 'ඉලක්කයට දුවන්න!',
        description = 'දැන් රිබන් පටිය වෙත දුවන්න!',
        type = 'warning'
    },
    End = {
        title = 'තරඟය අවසන්',
        description = 'ඔබ සාර්ථකව ඉලක්කය වෙත ළඟා විය!',
        type = 'success'
    },
    TimeUp = {
        title = 'කාලය අවසන්!',
        description = 'ඔබ නියමිත වේලාවට ඉලක්කය වෙත ළඟා වීමට අපොහොසත් විය.',
        type = 'error'
    },
    AlreadyInRace = {
        title = 'දැනටමත් තරඟරක!',
        description = 'ඔබ දැනටමත් තරඟයක නිරත වී ඇත.',
        type = 'error'
    },
    TooFar = {
        title = 'බොහෝ දුරයි!',
        description = 'පොල්ල අසලටම යන්න.',
        type = 'error'
    },
    Cancelled = {
        title = 'තරඟය අවලංගු විය!',
        description = 'ඔබ පොල්ලෙන් බොහෝ දුරස් විය.',
        type = 'error'
    },
    NoItem = {
        title = 'ඇතුළත් විය නොහැක!',
        description = 'මෙම තරඟයට සහභාගී වීමට ඔබට %s අවශ්‍ය වේ.',
        type = 'error'
    },
    ReceivedReward = {
        title = 'ත්‍යාගය ලැබුණි!',
        description = 'ඔබ තෑග්ගක් ලෙස %s %s ලබන ලදී!',
        type = 'success'
    },
    GlobalCooldown = {
        title = 'කරුණාකර රැඳී සිටින්න',
        description = 'ඊළඟ තරඟය සඳහා තව තත්පර %sක් ඉතිරිව ඇත.',
        type = 'error'
    }
}
