-- Configuration for CWRP Weapon Scanning System

ENABLE_SERVER_CONSOLE_LOGGING = true

WEAPON_SCANNER_WHITELIST = {"weapon_physgun", "gmod_tool"}
WEAPON_SCANNER_BLACKLIST = {"weapon_rpg", "weapon_frag"}
WEAPON_SCANNER_ROLE_BYPASS = {
    ["VIP"] = true,
    ["Sith"] = true
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