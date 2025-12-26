-- Auto-Loader for CWRP Weapon Scanning System

-- Print Initialization Message
print("[CWRP Weapon Scanning System] Initializing addon...")

-- Load Configurations
local configPath = "config/weapon_scanner_config.lua"
if file.Exists(configPath, "LUA") then
    include(configPath)
    AddCSLuaFile(configPath)
    print("[CWRP] Configuration loaded successfully.")
else
    print("[CWRP] Configuration file is missing!")
end

-- Load SWEPs
local swepFiles = file.Find("sweps/*.lua", "LUA")
for _, swepFile in ipairs(swepFiles) do
    include("sweps/" .. swepFile)
    AddCSLuaFile("sweps/" .. swepFile)
    print("[CWRP] Loaded SWEP: " .. swepFile)
end

-- Load Utilities
local utilPath = "utils/cwrp_logging_util.lua"
if file.Exists(utilPath, "LUA") then
    include(utilPath)
    AddCSLuaFile(utilPath)
    print("[CWRP] Loaded Logging Utility.")
else
    print("[CWRP] Logging utility is missing!")
end

-- Load NPCs
local npcFiles = file.Find("npcs/*.lua", "LUA")
for _, npcFile in ipairs(npcFiles) do
    include("npcs/" .. npcFile)
    AddCSLuaFile("npcs/" .. npcFile)
    print("[CWRP] Loaded NPC script: " .. npcFile)
end

-- Init Completion
print("[CWRP Weapon Scanning System] Addon loaded successfully!")