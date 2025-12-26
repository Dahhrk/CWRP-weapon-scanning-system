-- Auto-Loader for CWRP Weapon Scanning System

-- Print Initialization Message
print("[CWRP Weapon Scanning System] Initializing addon...")

-- Initialize Global ConfiscatedWeapons Table
if SERVER then
    ConfiscatedWeapons = ConfiscatedWeapons or {}
    
    -- Persistence Functions
    local DATA_DIR = "cwrp_weapon_scanner"
    local DATA_FILE = "confiscated_weapons.json"
    
    function CWRP_SaveConfiscatedWeapons()
        if not file.Exists(DATA_DIR, "DATA") then
            file.CreateDir(DATA_DIR)
        end
        
        local success, jsonData = pcall(util.TableToJSON, ConfiscatedWeapons)
        if not success or not jsonData then
            print("[CWRP] ERROR: Failed to serialize confiscated weapons data!")
            return false
        end
        
        file.Write(DATA_DIR .. "/" .. DATA_FILE, jsonData)
        print("[CWRP] Confiscated weapons saved to disk.")
        return true
    end
    
    function CWRP_LoadConfiscatedWeapons()
        if file.Exists(DATA_DIR .. "/" .. DATA_FILE, "DATA") then
            local jsonData = file.Read(DATA_DIR .. "/" .. DATA_FILE, "DATA")
            if not jsonData then
                print("[CWRP] ERROR: Failed to read confiscated weapons from disk!")
                ConfiscatedWeapons = {}
                return false
            end
            
            local success, parsedData = pcall(util.JSONToTable, jsonData)
            if not success or not parsedData then
                print("[CWRP] ERROR: Failed to parse confiscated weapons JSON!")
                ConfiscatedWeapons = {}
                return false
            end
            
            ConfiscatedWeapons = parsedData
            print("[CWRP] Loaded confiscated weapons from disk.")
            return true
        else
            ConfiscatedWeapons = {}
            print("[CWRP] No saved confiscated weapons found. Starting fresh.")
            return true
        end
    end
    
    -- Load confiscated weapons on startup
    CWRP_LoadConfiscatedWeapons()
end

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

-- Team Permission Check Function
function CWRP_CheckTeamPermission(ply, swepName)
    if not IsValid(ply) then return false end
    
    -- Get allowed teams for this SWEP
    local allowedTeams = SWEP_ALLOWED_TEAMS and SWEP_ALLOWED_TEAMS[swepName]
    if not allowedTeams then
        -- If no configuration exists, deny by default
        return false
    end
    
    local playerTeam = ply:Team()
    
    -- Check if player's team is in the allowed list
    for _, teamID in ipairs(allowedTeams) do
        if playerTeam == teamID then
            return true
        end
    end
    
    return false
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

-- Kill-to-Return Mechanic: Return confiscated weapons when confiscator dies
if SERVER then
    hook.Add("PlayerDeath", "CWRP_ReturnWeaponsOnDeath", function(victim, inflictor, attacker)
        if not IsValid(victim) then return end
        
        local victimSteamID = victim:SteamID()
        
        -- Check if this player confiscated weapons from anyone
        for targetSteamID, confiscationData in pairs(ConfiscatedWeapons) do
            if confiscationData.confiscatorSteamID == victimSteamID then
                -- Find the original owner and return their weapons
                for _, ply in ipairs(player.GetAll()) do
                    if ply:SteamID() == targetSteamID then
                        if confiscationData.weapons then
                            for _, weaponClass in ipairs(confiscationData.weapons) do
                                ply:Give(weaponClass)
                            end
                            ply:ChatPrint("Your confiscated weapons have been returned because the confiscator died!")
                        end
                        break
                    end
                end
                
                -- Remove from confiscated weapons table
                ConfiscatedWeapons[targetSteamID] = nil
            end
        end
        
        -- Save changes to disk
        CWRP_SaveConfiscatedWeapons()
    end)
end