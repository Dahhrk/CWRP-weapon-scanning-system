-- Configuration for CWRP Weapon Scanning System

ENABLE_SERVER_CONSOLE_LOGGING = true

WEAPON_SCANNER_WHITELIST = {"weapon_physgun", "gmod_tool"}
WEAPON_SCANNER_BLACKLIST = {"weapon_rpg", "weapon_frag"}
WEAPON_SCANNER_ROLE_BYPASS = {
    ["VIP"] = true,
    ["Sith"] = true
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

-- Stealth and Anti-Detection Configuration
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

-- Scan Message Customization
WEAPON_SCANNER_MESSAGES = {
    scanStart = "[SCANNING...]",
    scanComplete = "[SCAN COMPLETE]",
    noWeapons = "No weapons detected.",
    allowedHeader = "ALLOWED ITEMS:",
    blacklistedHeader = "BLACKLISTED ITEMS:",
    contrabandDetected = "⚠ CRITICAL CONTRABAND DETECTED ⚠",
    stealthBypass = "Scan bypassed - Stealth technology detected.",
    scanSound = "buttons/button14.wav", -- Optional scan sound
    playScanSound = true
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
    }
}

-- Delay (in seconds) before stripping unauthorized SWEP from player
SWEP_STRIP_DELAY = 0.1