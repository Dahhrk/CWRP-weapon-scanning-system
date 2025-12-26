--[[
================================================================================
    CWRP WEAPON SCANNING SYSTEM - CONFIGURATION FILE
================================================================================

    This is the centralized configuration file for the CWRP Weapon Scanning System.
    All settings for the scanning system can be customized here.
    
    STRUCTURE:
    1. General Settings - Global toggles and basic configuration
    2. Legacy Settings - Deprecated but kept for backwards compatibility
    3. Job-Based Bypass - Configure which jobs cannot be scanned
    4. Danger Level System - Color-coded threat levels for items
    5. Item-Job Exceptions - Job-specific item permissions
    6. Contraband Configuration - Critical contraband alerts
    7. Concealment System - Player item concealment mechanics
    8. Scanning Behavior - Systematic scanning configuration
    9. Messages & UI - Customizable text and notifications
    10. SWEP Permissions - Team-based SWEP access control
    
    ADMIN GUIDE:
    - Comments explain each setting's purpose and valid values
    - Default values are production-ready and can be used immediately
    - Customize settings to match your server's specific needs
    - Test changes on a development server before deploying to production
    
    For detailed usage examples, see EXAMPLES.md
    For feature documentation, see README.md
    
================================================================================
]]--

--[[
================================================================================
    SECTION 1: GENERAL SETTINGS
================================================================================
]]--

-- Enable/Disable Server Console Logging
-- Controls whether scan events are logged to the server console for debugging
-- Valid values: true (enable logging), false (disable logging)
-- Default: true (recommended for admin transparency)
-- Note: This does NOT affect Billy's Logs integration, which logs regardless of this setting
ENABLE_SERVER_CONSOLE_LOGGING = true

--[[
================================================================================
    SECTION 2: LEGACY SETTINGS (DEPRECATED)
================================================================================
    These settings are kept for backwards compatibility but are deprecated.
    Use the new Danger Level System and Job Bypass instead.
]]--

-- DEPRECATED: Legacy Whitelist
-- Items in this list were always shown as "allowed" in old system
-- Valid values: Table of weapon class names (strings)
-- Recommendation: Use ITEM_DANGER_LEVELS with "green" level instead
-- Example: {"weapon_physgun", "gmod_tool", "gmod_camera"}
WEAPON_SCANNER_WHITELIST = {"weapon_physgun", "gmod_tool"}

-- DEPRECATED: Legacy Blacklist
-- Items in this list were always shown as "blacklisted" in old system
-- Valid values: Table of weapon class names (strings)
-- Recommendation: Use ITEM_DANGER_LEVELS with "red" level instead
-- Example: {"weapon_rpg", "weapon_frag", "weapon_c4"}
WEAPON_SCANNER_BLACKLIST = {"weapon_rpg", "weapon_frag"}

-- DEPRECATED: Legacy Role Bypass
-- Roles that could bypass scanner detection in old system
-- Valid values: Table with role names as keys, true as values
-- Recommendation: Use WEAPON_SCANNER_JOB_BYPASS instead for team-based bypass
-- Example: ["VIP"] = true, ["Admin"] = true
WEAPON_SCANNER_ROLE_BYPASS = {
    ["VIP"] = true,
    ["Sith"] = true
}

--[[
================================================================================
    SECTION 3: JOB-BASED BYPASS CONFIGURATION
================================================================================
    This system replaces the deprecated Cloaking Device SWEP.
    Jobs configured here cannot be scanned by weapon scanners.
]]--

-- Job-Based Scan Bypass
-- Controls which jobs/teams are immune to weapon scanning
-- Valid values: Table with TEAM constants as keys, true as values
-- Default: Empty table (no jobs bypass scanning)
-- 
-- HOW IT WORKS:
-- - When a guard attempts to scan a player with a bypassed job, the scan is blocked
-- - Guard receives message: "This role cannot be scanned."
-- - All bypass attempts are logged for admin transparency
-- - Use this for: Spies, undercover agents, special ops roles
-- 
-- IMPORTANT NOTES:
-- - TEAM constants must be defined by your gamemode before this addon loads
-- - If team constants are not available, you can use numeric team IDs
-- - Example: [1] = true, [5] = true (where 1 and 5 are team IDs)
-- 
-- CONFIGURATION EXAMPLES:
-- Single job bypass:
--   WEAPON_SCANNER_JOB_BYPASS = {
--       [TEAM_SITHSPY] = true
--   }
-- 
-- Multiple jobs bypass:
--   WEAPON_SCANNER_JOB_BYPASS = {
--       [TEAM_SITHSPY] = true,
--       [TEAM_SPECIALAGENT] = true,
--       [TEAM_UNDERCOVER] = true
--   }
-- 
-- Using numeric team IDs (if TEAM constants not available):
--   WEAPON_SCANNER_JOB_BYPASS = {
--       [15] = true,  -- Sith Spy team ID
--       [22] = true   -- Special Agent team ID
--   }
WEAPON_SCANNER_JOB_BYPASS = {
    -- Add your bypass jobs here
    -- Example: [TEAM_SITHSPY] = true,
    -- Example: [TEAM_SPECIALAGENT] = true,
}

--[[
================================================================================
    SECTION 4: CONTRABAND & LEGACY ALERT CONFIGURATION
================================================================================
]]--

-- Critical Contraband List
-- Items in this list trigger special contraband alerts when detected
-- Valid values: Table of weapon class names (strings)
-- Default: Common high-danger items
-- 
-- HOW IT WORKS:
-- - Items in this list are automatically treated as "red" danger level
-- - Detection triggers "CRITICAL CONTRABAND DETECTED" header in scan results
-- - Compatible with new danger level system
-- 
-- RECOMMENDATION: Use ITEM_DANGER_LEVELS with "red" level instead for better control
-- 
-- CONFIGURATION EXAMPLES:
-- Standard contraband:
--   WEAPON_SCANNER_CONTRABAND = {
--       "weapon_rpg", "weapon_frag", "weapon_slam",
--       "ls_lightsaber", "weapon_c4"
--   }
WEAPON_SCANNER_CONTRABAND = {
    "weapon_rpg",
    "weapon_frag",
    "weapon_slam",
    "ls_lightsaber",
    "weapon_c4"
}

-- Contraband Alert Settings
-- Controls how and when guards are notified about high-danger items
-- 
-- SETTINGS:
-- enabled: Enable/disable contraband alerts
--   Valid values: true, false
--   Default: true
-- 
-- alertRadius: Radius in Hammer units to alert nearby players
--   Valid values: Any positive number (recommended: 300-1000)
--   Default: 500 (medium-sized area)
--   Note: 1 Hammer unit ≈ 1 inch, so 500 units ≈ 42 feet
-- 
-- soundEffect: Sound file path for alert notification
--   Valid values: Path to any valid sound file in your server
--   Default: "buttons/button17.wav" (standard GMod beep)
--   Examples: "ambient/alarms/klaxon1.wav", "buttons/blip1.wav"
-- 
-- playSound: Enable/disable alert sound effect
--   Valid values: true, false
--   Default: true
-- 
-- alertTeams: Which teams receive contraband alerts
--   Valid values: Table of TEAM constants
--   Default: Security teams (Shock, Temple Guard, 5th Fleet, Commanders)
--   Note: Only players on these teams within alertRadius will be notified
-- 
-- CONFIGURATION EXAMPLES:
-- Large alert radius for big maps:
--   alertRadius = 1000
-- 
-- Different alert sound:
--   soundEffect = "ambient/alarms/klaxon1.wav"
-- 
-- Silent alerts (no sound):
--   playSound = false
-- 
-- Different alert teams:
--   alertTeams = {TEAM_POLICE, TEAM_SWAT, TEAM_SECURITY}
WEAPON_SCANNER_CONTRABAND_ALERTS = {
    enabled = true,
    alertRadius = 500,
    soundEffect = "buttons/button17.wav",
    playSound = true,
    alertTeams = {
        TEAM_SHOCK,
        TEAM_TEMPLEGUARD,
        TEAM_5THFLEET,
        TEAM_COMMANDER
    }
}

--[[
================================================================================
    SECTION 5: DEPRECATED STEALTH CONFIGURATION
================================================================================
    These settings are deprecated. Use WEAPON_SCANNER_JOB_BYPASS instead.
]]--

-- DEPRECATED: Stealth Roles
-- DO NOT USE - This system is deprecated
-- Valid values: Table with role names as keys, true as values
-- Recommendation: Use WEAPON_SCANNER_JOB_BYPASS for team-based bypass instead
WEAPON_SCANNER_STEALTH_ROLES = {
    ["SithAssassin"] = true,
    ["Spy"] = true
}

-- DEPRECATED: Stealth Teams
-- DO NOT USE - This system is deprecated
-- Valid values: Table with TEAM constants as keys, true as values
-- Recommendation: Use WEAPON_SCANNER_JOB_BYPASS for team-based bypass instead
WEAPON_SCANNER_STEALTH_TEAMS = {
    -- TEAM_SITHSPY = true,
    -- TEAM_BOUNTYHUNTER = true
}

--[[
================================================================================
    SECTION 6: DANGER LEVEL SYSTEM
================================================================================
    The danger level system categorizes items into color-coded threat levels.
    This provides visual clarity during scans and helps guards quickly identify risks.
]]--

-- Item Danger Levels
-- Defines color-coded threat levels for items during weapon scans
-- 
-- DANGER LEVELS:
-- "green" - Low threat items
--   - Medical supplies, repair kits, common tools
--   - Displayed with [✓] indicator
--   - Examples: med_kit, armor_kit, gmod_tool, gmod_camera
-- 
-- "yellow" - Questionable/Restricted items
--   - Unauthorized tools, basic weapons, suspicious items
--   - Displayed with [!] indicator
--   - Examples: weapon_pistol, lockpick, keypad_cracker
-- 
-- "red" - High-danger contraband
--   - Explosives, heavy weapons, illegal items, force-sensitive items
--   - Displayed with [⚠] indicator
--   - Triggers guard alerts if enabled
--   - Examples: weapon_rpg, ls_lightsaber, weapon_c4, explosives
-- 
-- VALID VALUES: "green", "yellow", "red"
-- 
-- HOW IT WORKS:
-- - During scans, items are grouped by danger level
-- - Items not in this table default to "yellow" (questionable)
-- - Overridden by ITEM_JOB_EXCEPTIONS for specific jobs
-- - Items in legacy WEAPON_SCANNER_CONTRABAND automatically treated as "red"
-- - Items in legacy WEAPON_SCANNER_WHITELIST automatically treated as "green"
-- 
-- CUSTOMIZATION TIPS:
-- - Balance between realism and gameplay
-- - Common server items should be "green" to reduce scan clutter
-- - Reserve "red" for truly dangerous/illegal items
-- - Use "yellow" for items that are contextually suspicious
-- 
-- CONFIGURATION EXAMPLES:
-- Military base (weapons are more acceptable):
--   ["weapon_pistol"] = "yellow"  -- Basic sidearm is questionable
--   ["weapon_rifle"] = "yellow"   -- Standard rifle is questionable
--   ["weapon_rpg"] = "red"         -- Heavy weapons still red
-- 
-- Civilian area (stricter controls):
--   ["weapon_pistol"] = "red"      -- Any weapon is high danger
--   ["weapon_knife"] = "red"       -- Even melee is dangerous
--   ["lockpick"] = "red"           -- Criminal tools are contraband
ITEM_DANGER_LEVELS = {
    -- GREEN LEVEL: Low threat items (consumables, common tools, building tools)
    ["weapon_physgun"] = "green",      -- Physics gun (admin/build tool)
    ["gmod_tool"] = "green",           -- Toolgun (build tool)
    ["gmod_camera"] = "green",         -- Camera (photography)
    ["med_kit"] = "green",             -- Medical kit (healing item)
    ["armor_kit"] = "green",           -- Armor repair kit
    
    -- YELLOW LEVEL: Questionable/Restricted items (unauthorized tools, basic weapons)
    ["weapon_pistol"] = "yellow",      -- Basic pistol (unauthorized sidearm)
    ["weapon_smg1"] = "yellow",        -- SMG (unauthorized automatic weapon)
    ["lockpick"] = "yellow",           -- Lockpicking tool (criminal tool)
    ["keypad_cracker"] = "yellow",     -- Keypad cracker (hacking tool)
    
    -- RED LEVEL: High-danger contraband (explosives, heavy weapons, force items)
    ["weapon_rpg"] = "red",            -- RPG launcher (heavy explosive weapon)
    ["weapon_frag"] = "red",           -- Fragmentation grenade (explosive)
    ["weapon_slam"] = "red",           -- SLAM mine (explosive trap)
    ["weapon_c4"] = "red",             -- C4 explosive (timed explosive)
    ["ls_lightsaber"] = "red",         -- Lightsaber (force-sensitive weapon)
    ["weapon_lightsaber"] = "red",     -- Alternative lightsaber class
    ["tfa_detonator"] = "red",         -- Detonator (explosive trigger)
    ["realistic_hook"] = "red"         -- Grappling hook (infiltration tool)
    
    -- ADD YOUR CUSTOM ITEMS BELOW:
    -- Copy the format above and add your server's custom weapons
    -- Example: ["custom_weapon"] = "yellow",
}

--[[
================================================================================
    SECTION 7: ITEM-JOB EXCEPTION SYSTEM
================================================================================
    This system allows you to define job-specific permissions for items.
    Exceptions override the default danger levels from ITEM_DANGER_LEVELS.
]]--

-- Item-Job Exceptions
-- Defines which items are allowed, restricted, or forbidden for specific jobs
-- 
-- FORMAT: 
--   ["weapon_class_name"] = {
--       [TEAM_CONSTANT] = "permission_level"
--   }
-- 
-- PERMISSION LEVELS:
-- "allowed" - Item is authorized for this job (shown with [✓] indicator)
-- "green"   - Low threat for this job
-- "yellow"  - Questionable for this job
-- "red"     - High danger/contraband for this job
-- 
-- VALID VALUES: "allowed", "green", "yellow", "red"
-- 
-- HOW IT WORKS:
-- - Job exceptions override default danger levels from ITEM_DANGER_LEVELS
-- - If a player's job has an exception for an item, that level is used
-- - If no exception exists, the default danger level is used
-- - Use "allowed" for job-specific equipment that should never be flagged
-- 
-- USE CASES:
-- - Lightsabers: Allowed for Jedi/Sith, contraband for civilians
-- - Heavy weapons: Questionable for ARC troopers, contraband for civilians
-- - Medical supplies: Allowed for medics, green for everyone else
-- - Lockpicks: Allowed for locksmiths, red for civilians
-- 
-- IMPORTANT NOTES:
-- - TEAM constants must be defined by your gamemode before this addon loads
-- - If team constants are not available, you can use numeric team IDs
-- - Only define exceptions when default danger level needs to change per job
-- - Leave empty {} for weapons that should use default danger level for all jobs
-- 
-- CONFIGURATION EXAMPLES:
-- 
-- Example 1: Lightsabers (force-sensitive weapon)
--   ["weapon_lightsaber"] = {
--       [TEAM_JEDI] = "allowed",        -- Jedi authorized to carry
--       [TEAM_SITH] = "allowed",         -- Sith authorized to carry
--       [TEAM_PADAWAN] = "yellow",       -- Padawans questionable (training)
--       [TEAM_CIVILIAN] = "red"          -- Civilians absolutely forbidden
--   }
-- 
-- Example 2: Heavy weapons (military equipment)
--   ["weapon_rpg"] = {
--       [TEAM_HEAVY] = "yellow",         -- Heavy gunner can have (questionable but ok)
--       [TEAM_ARCTROOP] = "yellow",      -- ARC trooper can have (special ops)
--       [TEAM_CIVILIAN] = "red"          -- Civilians forbidden
--   }
-- 
-- Example 3: Medical equipment (specialized gear)
--   ["advanced_medkit"] = {
--       [TEAM_MEDIC] = "allowed",        -- Medic authorized
--       [TEAM_DOCTOR] = "allowed",       -- Doctor authorized
--       -- All other jobs use default danger level from ITEM_DANGER_LEVELS
--   }
-- 
-- Example 4: Using numeric team IDs (if TEAM constants not available)
--   ["weapon_lightsaber"] = {
--       [5] = "allowed",     -- Team ID 5 = Jedi
--       [6] = "allowed",     -- Team ID 6 = Sith
--       [1] = "red"          -- Team ID 1 = Civilian
--   }
ITEM_JOB_EXCEPTIONS = {
    -- Lightsaber exceptions (example - uncomment and customize for your server)
    ["weapon_lightsaber"] = {
        -- [TEAM_JEDI] = "allowed",      -- Jedi can have lightsabers (authorized equipment)
        -- [TEAM_SITH] = "allowed",       -- Sith can have lightsabers (authorized equipment)
        -- [TEAM_CIVILIAN] = "red"        -- Civilians cannot have lightsabers (contraband)
    },
    ["ls_lightsaber"] = {
        -- [TEAM_JEDI] = "allowed",       -- Jedi can have lightsabers (authorized equipment)
        -- [TEAM_SITH] = "allowed",       -- Sith can have lightsabers (authorized equipment)
        -- [TEAM_CIVILIAN] = "red"        -- Civilians cannot have lightsabers (contraband)
    },
    
    -- Heavy weapon exceptions (example - uncomment and customize for your server)
    ["weapon_rpg"] = {
        -- [TEAM_HEAVY] = "yellow",       -- Heavy class can have RPG (questionable but allowed)
        -- [TEAM_CIVILIAN] = "red"        -- Civilians definitely cannot have RPG
    }
    
    -- ADD YOUR CUSTOM EXCEPTIONS BELOW:
    -- Copy the format above and add exceptions for your server's jobs and weapons
    -- Only add exceptions when you need job-specific permissions
    -- Example:
    -- ["custom_weapon"] = {
    --     [TEAM_CUSTOM] = "allowed",
    --     [TEAM_CIVILIAN] = "red"
    -- },
}

--[[
================================================================================
    SECTION 8: CONCEALMENT SYSTEM CONFIGURATION
================================================================================
    The concealment system allows players to hide items in special concealed slots
    to avoid detection during scans. This adds strategic depth to security gameplay.
]]--

-- Concealment Mechanic Settings
-- Controls how players can hide items from weapon scans
-- 
-- SETTINGS:
-- enabled: Enable/disable the entire concealment system
--   Valid values: true, false
--   Default: true
--   Note: If disabled, players cannot conceal any items
-- 
-- maxConcealedSlots: Maximum number of items a player can conceal
--   Valid values: Any positive integer (recommended: 1-3)
--   Default: 2
--   Note: Higher values make concealment too powerful, lower values too restrictive
-- 
-- concealTime: Base time in seconds required to conceal an item
--   Valid values: Any positive number (recommended: 2-5)
--   Default: 3 seconds
--   Note: Player must remain still during this time or concealment is cancelled
-- 
-- largeItemMultiplier: Time multiplier for large/bulky items
--   Valid values: Any positive number (recommended: 1.5-3)
--   Default: 2 (doubles concealment time)
--   Note: Applied to items like rifles, heavy weapons
--   Example: 3 second base × 2 multiplier = 6 seconds for large items
-- 
-- dangerItemMultiplier: Time multiplier for high-danger items
--   Valid values: Any positive number (recommended: 1.2-2)
--   Default: 1.5 (adds 50% more time)
--   Note: Applied to items marked as "red" danger level
--   Example: 3 second base × 1.5 multiplier = 4.5 seconds for red items
--   Note: Both multipliers stack (large + dangerous = 2 × 1.5 = 3x time)
-- 
-- concealKey: Keyboard key players hold to conceal items
--   Valid values: Any KEY_ constant (KEY_E, KEY_R, KEY_F, etc.)
--   Default: KEY_E
--   Note: Players must hold this key during concealment progress
-- 
-- unconcealableItems: Items that cannot be concealed (too large/obvious)
--   Valid values: Table of weapon class names (strings)
--   Default: Large explosives and launchers
--   Examples: RPGs, C4, detonators, heavy weapons
--   Note: These items will always be visible during scans
-- 
-- HOW CONCEALMENT WORKS:
-- 1. Player uses command: cwrp_conceal_weapon <weapon_class>
-- 2. Progress bar appears showing concealment time
-- 3. Player must stay still (< 50 units movement) or concealment cancels
-- 4. After time completes, item moves to concealed slot
-- 5. Concealed items are hidden during weapon scans
-- 6. Player can reveal items with: cwrp_reveal_weapon <weapon_class>
-- 
-- GAMEPLAY BALANCE:
-- - Concealment requires time and staying still (vulnerable during process)
-- - Limited slots prevent hiding entire inventory
-- - Large/dangerous items take longer to conceal
-- - Some items cannot be concealed at all
-- - Guards should watch for suspicious behavior during checkpoint approaches
-- 
-- CUSTOMIZATION TIPS:
-- - Increase concealTime for more realistic/difficult concealment
-- - Reduce maxConcealedSlots for stricter security
-- - Add more unconcealableItems for items that are too obvious to hide
-- - Adjust multipliers to balance large vs small item concealment
-- 
-- CONFIGURATION EXAMPLES:
-- 
-- Strict security (hard to conceal):
--   maxConcealedSlots = 1
--   concealTime = 5
--   largeItemMultiplier = 3
-- 
-- Lenient security (easy to conceal):
--   maxConcealedSlots = 3
--   concealTime = 2
--   largeItemMultiplier = 1.5
-- 
-- Disable concealment entirely:
--   enabled = false
-- 
-- More unconcealable items (stricter):
--   unconcealableItems = {
--       "weapon_rpg", "weapon_slam", "weapon_c4", "tfa_detonator",
--       "weapon_shotgun", "weapon_crossbow", "weapon_smg1"
--   }
WEAPON_SCANNER_CONCEALMENT = {
    enabled = true,
    maxConcealedSlots = 2,
    concealTime = 3,
    largeItemMultiplier = 2,
    dangerItemMultiplier = 1.5,
    concealKey = KEY_E,
    unconcealableItems = {
        "weapon_rpg",       -- Too large: Rocket launcher
        "weapon_slam",      -- Too large: SLAM mine
        "weapon_c4",        -- Too obvious: C4 explosive
        "tfa_detonator"     -- Too obvious: Detonator
    }
}

--[[
================================================================================
    SECTION 9: SYSTEMATIC SCANNING CONFIGURATION
================================================================================
    Controls the progressive slot-by-slot scanning behavior.
    This creates tension and realism during security checkpoints.
]]--

-- Systematic Scan Settings
-- Controls how weapon scans progress through player inventory
-- 
-- SETTINGS:
-- enabled: Enable/disable slot-by-slot progressive scanning
--   Valid values: true, false
--   Default: true
--   Note: If disabled, all items are scanned instantly (less immersive)
-- 
-- slotDelay: Time delay in seconds between scanning each inventory slot
--   Valid values: Any positive number (recommended: 0-2)
--   Default: 1 second per slot
--   Special: Set to 0 for instant scanning (no delay)
--   Note: Creates dramatic tension during scans
--   Example: 5 weapons with 1 second delay = 5 second total scan time
-- 
-- showProgress: Show scan progress messages to the guard
--   Valid values: true, false
--   Default: true
--   Note: Displays "[SCANNING] Slot 3/5..." messages during scan
-- 
-- cancelOnMove: Cancel scan if target moves too far away
--   Valid values: true, false
--   Default: false
--   Note: If true and target exceeds maxScanDistance, scan cancels
--   Warning: Setting to true may cause frustration in busy areas
-- 
-- maxScanDistance: Maximum distance in Hammer units before scan cancels
--   Valid values: Any positive number (recommended: 100-500)
--   Default: 200 units (about 16-17 feet)
--   Note: Only applies if cancelOnMove is true
--   Tip: Larger values are more forgiving to player movement
-- 
-- HOW IT WORKS:
-- - Guard initiates scan on target player
-- - System scans inventory slots one at a time with delay between each
-- - Progress messages show "[SCANNING] Slot X/Y..." if showProgress enabled
-- - If cancelOnMove enabled and target moves beyond maxScanDistance, scan stops
-- - After all slots scanned, full results are displayed
-- 
-- GAMEPLAY CONSIDERATIONS:
-- - Higher slotDelay creates more tension but slows RP flow
-- - Lower slotDelay speeds up checkpoints but reduces immersion
-- - cancelOnMove creates realism but may frustrate legitimate players
-- - showProgress helps guards understand scan is working
-- 
-- CUSTOMIZATION TIPS:
-- - Use slotDelay = 0 for instant scans on busy servers
-- - Use slotDelay = 1-2 for immersive RP on dedicated servers
-- - Enable cancelOnMove only if you want strict checkpoint control
-- - Disable showProgress if you want cleaner chat (less spam)
-- 
-- CONFIGURATION EXAMPLES:
-- 
-- Fast scanning (busy server):
--   slotDelay = 0        -- Instant scan
--   showProgress = false -- No spam
-- 
-- Immersive scanning (RP server):
--   slotDelay = 2        -- Slow, dramatic scan
--   showProgress = true  -- Show progress
--   cancelOnMove = true  -- Must stay still
-- 
-- Balanced scanning (default):
--   slotDelay = 1        -- Moderate speed
--   showProgress = true  -- Feedback for guard
--   cancelOnMove = false -- Forgiving
WEAPON_SCANNER_SYSTEMATIC = {
    enabled = true,
    slotDelay = 1,
    showProgress = true,
    cancelOnMove = false,
    maxScanDistance = 200
}

--[[
================================================================================
    SECTION 10: MESSAGES & UI CUSTOMIZATION
================================================================================
    Customize all text messages and notifications shown during scans.
    Personalize the scanning experience to match your server's theme.
]]--

-- Scan Message Customization
-- All text messages displayed during weapon scanning operations
-- 
-- SCAN FLOW MESSAGES:
-- scanStart: Message shown when scan begins
-- scanComplete: Message shown when scan finishes
-- noWeapons: Message when target has no weapons
-- 
-- CATEGORY HEADERS (Item Organization):
-- allowedHeader: Header for job-authorized items
-- blacklistedHeader: Header for legacy blacklisted items (deprecated)
-- dangerLevelRed: Header for high-danger items (red level)
-- dangerLevelYellow: Header for questionable items (yellow level)
-- dangerLevelGreen: Header for low-threat items (green level)
-- 
-- SPECIAL MESSAGES:
-- contrabandDetected: Warning shown when critical contraband found
-- stealthBypass: Message when stealth technology detected (deprecated)
-- jobBypass: Message when scanning a bypass-enabled job
-- 
-- ALERT MESSAGES (Sent to nearby guards):
-- dangerAlert: Format for high-danger item alerts
--   %s placeholders: First = item name, Second = player name
-- restrictedAlert: Format for restricted item alerts
--   %s placeholders: First = item name, Second = player name
-- 
-- SOUND EFFECTS:
-- scanSound: Sound file played when scan completes
--   Valid values: Path to any valid sound file
--   Examples: "buttons/button14.wav", "buttons/blip1.wav"
-- playScanSound: Enable/disable scan completion sound
--   Valid values: true, false
-- 
-- CUSTOMIZATION TIPS:
-- - Keep messages concise for readability in chat
-- - Use clear headers so guards can quickly identify item categories
-- - Match your server's RP theme (military, sci-fi, modern, etc.)
-- - Test message length to ensure they don't overflow chat
-- - Use color codes if your gamemode supports them
-- 
-- COLOR MATCHING FOR DANGER LEVELS:
-- You can add color codes to match danger levels visually:
-- 🟢 Green items: Use green color code if available
-- 🟡 Yellow items: Use yellow/orange color code if available
-- 🔴 Red items: Use red color code if available
-- 
-- Example with DarkRP color codes (if supported):
--   dangerLevelRed = Color(255, 0, 0) .. "HIGH-DANGER ITEMS:" .. Color(255, 255, 255)
-- 
-- CONFIGURATION EXAMPLES:
-- 
-- Military theme:
--   scanStart = "[SECURITY SCAN INITIATED]"
--   scanComplete = "[SCAN COMPLETE - PROCESSING RESULTS]"
--   dangerLevelRed = "⚠ UNAUTHORIZED MILITARY HARDWARE ⚠"
-- 
-- Sci-fi theme:
--   scanStart = "[BIOMETRIC SCAN ACTIVE...]"
--   scanComplete = "[SCAN SEQUENCE COMPLETE]"
--   dangerLevelRed = "⚠ CONTRABAND DETECTED - ALERT SECURITY ⚠"
-- 
-- Minimal theme:
--   scanStart = "Scanning..."
--   scanComplete = "Done."
--   dangerLevelRed = "Contraband:"
-- 
-- Custom alert messages:
--   dangerAlert = "🚨 ALERT: %s detected on %s - RESPOND IMMEDIATELY"
--   restrictedAlert = "⚠ WARNING: %s found on %s - investigate"
WEAPON_SCANNER_MESSAGES = {
    -- Scan flow messages
    scanStart = "[SCANNING...]",
    scanComplete = "[SCAN COMPLETE]",
    noWeapons = "No weapons detected.",
    
    -- Category headers (item organization)
    allowedHeader = "ALLOWED ITEMS:",
    blacklistedHeader = "BLACKLISTED ITEMS:",
    dangerLevelRed = "HIGH-DANGER ITEMS:",
    dangerLevelYellow = "QUESTIONABLE ITEMS:",
    dangerLevelGreen = "LOW-THREAT ITEMS:",
    
    -- Special condition messages
    contrabandDetected = "⚠ CRITICAL CONTRABAND DETECTED ⚠",
    stealthBypass = "Scan bypassed - Stealth technology detected.",
    jobBypass = "This role cannot be scanned.",
    
    -- Alert messages for guards (use %s for item and player name placeholders)
    dangerAlert = "[ALERT] High-danger item detected: %s in %s's inventory!",
    restrictedAlert = "[ALERT] Restricted item detected: %s on %s",
    
    -- Sound effects
    scanSound = "buttons/button14.wav",
    playScanSound = true
}

--[[
================================================================================
    SECTION 11: SWEP TEAM PERMISSIONS
================================================================================
    Controls which teams can use each SWEP (Special Weapon) in the system.
    This ensures only authorized security personnel can use scanning tools.
]]--

-- Team-Based SWEP Access Control
-- Configure which teams are allowed to use each weapon scanner SWEP
-- 
-- FORMAT:
--   ["swep_class_name"] = {
--       TEAM_CONSTANT1,
--       TEAM_CONSTANT2,
--       ...
--   }
-- 
-- SWEP TYPES:
-- weapon_scanner: The primary scanning tool for detecting weapons
-- weapon_confiscator: Tool for confiscating unauthorized items
-- weapon_drop: Tool for dropping confiscated items
-- weapon_cloaking_device: DEPRECATED - Use WEAPON_SCANNER_JOB_BYPASS instead
-- 
-- HOW IT WORKS:
-- - When a player equips a SWEP, their team is checked against this list
-- - If their team is not in the allowed list, SWEP is removed automatically
-- - Attempt is logged for admin review
-- - Only players on authorized teams can deploy and use these SWEPs
-- 
-- IMPORTANT NOTES:
-- - TEAM constants must be defined by your gamemode before this addon loads
-- - If team constants are not available, you can use numeric team IDs
-- - Example: {1, 2, 3} where numbers are team IDs
-- - Typically only security/guard teams should have access
-- - Remove teams from lists to restrict access
-- 
-- TYPICAL SECURITY TEAMS (Clone Wars RP):
-- TEAM_SHOCK: Shock troopers (military police)
-- TEAM_TEMPLEGUARD: Temple guards (Jedi security)
-- TEAM_5THFLEET: 5th Fleet security
-- TEAM_COMMANDER: Military commanders
-- 
-- CUSTOMIZATION TIPS:
-- - Only give scanner access to teams that enforce security
-- - Confiscator should have same or more restricted access than scanner
-- - weapon_drop usually same teams as confiscator
-- - Be conservative - too many teams with access reduces RP value
-- - Test team restrictions on dev server before production deployment
-- 
-- CONFIGURATION EXAMPLES:
-- 
-- Strict access (only shock troopers):
--   ["weapon_scanner"] = {
--       TEAM_SHOCK
--   }
-- 
-- Multiple security teams:
--   ["weapon_scanner"] = {
--       TEAM_SHOCK,
--       TEAM_TEMPLEGUARD,
--       TEAM_SECURITY,
--       TEAM_MARSHAL
--   }
-- 
-- Using numeric team IDs (if TEAM constants not available):
--   ["weapon_scanner"] = {
--       5,   -- Shock trooper team ID
--       12,  -- Temple guard team ID
--       18   -- Commander team ID
--   }
-- 
-- Different access levels for different tools:
--   ["weapon_scanner"] = {TEAM_SHOCK, TEAM_GUARD, TEAM_SECURITY}
--   ["weapon_confiscator"] = {TEAM_SHOCK, TEAM_GUARD}  -- More restricted
--   ["weapon_drop"] = {TEAM_SHOCK}  -- Even more restricted
SWEP_ALLOWED_TEAMS = {
    -- Weapon Scanner: Primary scanning tool
    -- Default: Common security teams in Clone Wars RP
    ["weapon_scanner"] = {
        TEAM_SHOCK,
        TEAM_TEMPLEGUARD,
        TEAM_5THFLEET,
        TEAM_COMMANDER
    },
    
    -- Weapon Confiscator: Tool for taking items
    -- Default: Same teams as scanner (adjust if needed)
    ["weapon_confiscator"] = {
        TEAM_SHOCK,
        TEAM_TEMPLEGUARD,
        TEAM_5THFLEET,
        TEAM_COMMANDER
    },
    
    -- Weapon Drop: Tool for dropping confiscated items
    -- Default: Same teams as confiscator (adjust if needed)
    ["weapon_drop"] = {
        TEAM_SHOCK,
        TEAM_TEMPLEGUARD,
        TEAM_5THFLEET,
        TEAM_COMMANDER
    },
    
    -- Weapon Cloaking Device: DEPRECATED
    -- This SWEP is deprecated - use WEAPON_SCANNER_JOB_BYPASS instead
    -- Kept for backwards compatibility but will show deprecation warning
    -- Recommendation: Remove this from job loadouts and use job bypass system
    ["weapon_cloaking_device"] = {
        -- DEPRECATED: Configure job-based bypass in WEAPON_SCANNER_JOB_BYPASS instead
        -- Leave empty to prevent any team from using deprecated cloaking device
    }
}

-- SWEP Strip Delay
-- Time delay in seconds before removing unauthorized SWEP from player
-- Valid values: Any positive number (recommended: 0.1-1)
-- Default: 0.1 seconds
-- 
-- HOW IT WORKS:
-- - When unauthorized player equips a SWEP, system waits this long before removing it
-- - Short delay prevents instant removal (better UX, allows notification to display)
-- - Too long allows abuse, too short may cause issues
-- 
-- CUSTOMIZATION:
-- - 0.1 = Nearly instant removal (recommended)
-- - 0.5 = Half second delay (more warning time)
-- - 1.0 = One second delay (generous warning)
SWEP_STRIP_DELAY = 0.1

--[[
================================================================================
    END OF CONFIGURATION FILE
================================================================================
    
    You have reached the end of the configuration file.
    All settings above can be customized to match your server's needs.
    
    TESTING CHECKLIST:
    ✓ Review all TEAM constants match your gamemode
    ✓ Test weapon scanner with different jobs
    ✓ Verify danger levels display correctly
    ✓ Test concealment system with various items
    ✓ Confirm job bypass works for configured teams
    ✓ Check alert notifications reach correct teams
    ✓ Validate SWEP permissions for all teams
    
    SUPPORT:
    - Documentation: See README.md and EXAMPLES.md
    - Issues: Report on GitHub repository
    - Community: Check your server's Discord or forums
    
    Thank you for using the CWRP Weapon Scanning System!
================================================================================
]]--