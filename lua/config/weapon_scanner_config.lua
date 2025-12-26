-- Configuration for CWRP Weapon Scanning System

ENABLE_SERVER_CONSOLE_LOGGING = true

WEAPON_SCANNER_WHITELIST = {"weapon_physgun", "gmod_tool"}
WEAPON_SCANNER_BLACKLIST = {"weapon_rpg", "weapon_frag"}
WEAPON_SCANNER_ROLE_BYPASS = {
    ["VIP"] = true,
    ["Sith"] = true
}

-- Job-Based Scan Bypass Configuration
-- Jobs with bypassScan = true cannot be scanned
-- Example usage: WEAPON_SCANNER_JOB_BYPASS[TEAM_SITHSPY] = true
WEAPON_SCANNER_JOB_BYPASS = {
    -- Add job IDs that should bypass scanning
    -- Example: [TEAM_SITHSPY] = true,
    -- Example: [TEAM_SPECIALAGENT] = true
}

-- Critical Contraband Configuration
-- Items in this list will trigger special alerts when detected
WEAPON_SCANNER_CONTRABAND = {
    "weapon_rpg",
    "weapon_frag",
    "weapon_slam",
    "ls_lightsaber",
    "weapon_c4"
}

-- Contraband Alert Settings
WEAPON_SCANNER_CONTRABAND_ALERTS = {
    enabled = true,
    alertRadius = 500, -- Radius in units to alert nearby players
    soundEffect = "buttons/button17.wav", -- Optional sound effect path
    playSound = true,
    alertTeams = { -- Teams that should receive contraband alerts
        TEAM_SHOCK,
        TEAM_TEMPLEGUARD,
        TEAM_5THFLEET,
        TEAM_COMMANDER
    }
}

-- Stealth and Anti-Detection Configuration (DEPRECATED - Use WEAPON_SCANNER_JOB_BYPASS instead)
-- Roles that can bypass scanner detection
WEAPON_SCANNER_STEALTH_ROLES = {
    ["SithAssassin"] = true,
    ["Spy"] = true
}

-- Teams that can bypass scanner detection
WEAPON_SCANNER_STEALTH_TEAMS = {
    -- TEAM_SITHSPY = true,
    -- TEAM_BOUNTYHUNTER = true
}

-- Item Danger Level Configuration
-- Defines color-coded threat levels for items during scans
-- green = Low threat (consumables, common tools)
-- yellow = Questionable/Restricted (unauthorized tools, small drugs)
-- red = High-danger contraband (lightsabers, explosives)
ITEM_DANGER_LEVELS = {
    -- Green - Low threat
    ["weapon_physgun"] = "green",
    ["gmod_tool"] = "green",
    ["gmod_camera"] = "green",
    ["med_kit"] = "green",
    ["armor_kit"] = "green",
    
    -- Yellow - Questionable/Restricted
    ["weapon_pistol"] = "yellow",
    ["weapon_smg1"] = "yellow",
    ["lockpick"] = "yellow",
    ["keypad_cracker"] = "yellow",
    
    -- Red - High-danger contraband
    ["weapon_rpg"] = "red",
    ["weapon_frag"] = "red",
    ["weapon_slam"] = "red",
    ["weapon_c4"] = "red",
    ["ls_lightsaber"] = "red",
    ["weapon_lightsaber"] = "red",
    ["tfa_detonator"] = "red",
    ["realistic_hook"] = "red"
}

-- Item-Job Exception Configuration
-- Defines which items are allowed or blocked for specific jobs
-- Format: ["weapon_class"] = { [TEAM_ID] = "allowed" or "red" or "yellow" or "green" }
ITEM_JOB_EXCEPTIONS = {
    -- Example: Lightsabers
    ["weapon_lightsaber"] = {
        -- [TEAM_JEDI] = "allowed",      -- Jedi can have lightsabers (shows as allowed)
        -- [TEAM_SITH] = "allowed",       -- Sith can have lightsabers
        -- [TEAM_CIVILIAN] = "red"        -- Civilians cannot have lightsabers (high danger)
    },
    ["ls_lightsaber"] = {
        -- [TEAM_JEDI] = "allowed",
        -- [TEAM_SITH] = "allowed",
        -- [TEAM_CIVILIAN] = "red"
    },
    -- Example: Republic weapons
    ["weapon_rpg"] = {
        -- [TEAM_HEAVY] = "yellow",       -- Heavy class can have RPG (questionable but allowed)
        -- [TEAM_CIVILIAN] = "red"        -- Civilians definitely cannot
    }
}

-- Concealment Mechanic Configuration
WEAPON_SCANNER_CONCEALMENT = {
    enabled = true,
    maxConcealedSlots = 2,              -- Maximum number of items that can be concealed
    concealTime = 3,                     -- Base time in seconds to conceal an item
    largeItemMultiplier = 2,             -- Time multiplier for large items
    dangerItemMultiplier = 1.5,          -- Time multiplier for high-danger items
    concealKey = KEY_E,                  -- Key to hold for concealment (E key)
    -- Items that cannot be concealed
    unconcealableItems = {
        "weapon_rpg",
        "weapon_slam",
        "weapon_c4",
        "tfa_detonator"
    }
}

-- Systematic Scan Configuration
WEAPON_SCANNER_SYSTEMATIC = {
    enabled = true,                      -- Enable slot-by-slot scanning
    slotDelay = 1,                       -- Delay in seconds between scanning each slot
    showProgress = true,                 -- Show scan progress to the guard
    cancelOnMove = false,                -- Whether to cancel scan if target moves
    maxScanDistance = 200                -- Maximum distance for systematic scan
}

-- Scan Message Customization
WEAPON_SCANNER_MESSAGES = {
    scanStart = "[SCANNING...]",
    scanComplete = "[SCAN COMPLETE]",
    noWeapons = "No weapons detected.",
    allowedHeader = "ALLOWED ITEMS:",
    blacklistedHeader = "BLACKLISTED ITEMS:",
    contrabandDetected = "⚠ CRITICAL CONTRABAND DETECTED ⚠",
    stealthBypass = "Scan bypassed - Stealth technology detected.",
    jobBypass = "This role cannot be scanned.",
    scanSound = "buttons/button14.wav", -- Optional scan sound
    playScanSound = true,
    -- Danger level headers
    dangerLevelRed = "HIGH-DANGER ITEMS:",
    dangerLevelYellow = "QUESTIONABLE ITEMS:",
    dangerLevelGreen = "LOW-THREAT ITEMS:",
    -- Alert messages
    dangerAlert = "[ALERT] High-danger item detected: %s in %s's inventory!",
    restrictedAlert = "[ALERT] Restricted item detected: %s on %s"
}

-- Team-Based Restrictions for SWEPs
-- Configure which teams are allowed to use each SWEP
-- NOTE: Team constants (TEAM_SHOCK, TEAM_TEMPLEGUARD, etc.) must be defined
-- by your server's gamemode/job system before this addon loads.
-- If team constants are not available, you can use team IDs directly (e.g., 1, 2, 3)
SWEP_ALLOWED_TEAMS = {
    ["weapon_scanner"] = {
        TEAM_SHOCK,
        TEAM_TEMPLEGUARD,
        TEAM_5THFLEET,
        TEAM_COMMANDER
    },
    ["weapon_confiscator"] = {
        TEAM_SHOCK,
        TEAM_TEMPLEGUARD,
        TEAM_5THFLEET,
        TEAM_COMMANDER
    },
    ["weapon_drop"] = {
        TEAM_SHOCK,
        TEAM_TEMPLEGUARD,
        TEAM_5THFLEET,
        TEAM_COMMANDER
    },
    ["weapon_cloaking_device"] = {
        -- DEPRECATED: Cloaking device has been replaced with job-based bypass
        -- Configure which teams can use the cloaking device (if enabled)
        -- Example: TEAM_SITHSPY, TEAM_BOUNTYHUNTER
    }
}

-- Delay (in seconds) before stripping unauthorized SWEP from player
SWEP_STRIP_DELAY = 0.1