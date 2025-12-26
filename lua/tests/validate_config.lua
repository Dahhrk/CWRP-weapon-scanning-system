--[[
================================================================================
    CWRP WEAPON SCANNING SYSTEM - CONFIGURATION VALIDATOR
================================================================================
    
    This script validates your weapon_scanner_config.lua file to ensure:
    1. The file loads without Lua syntax errors
    2. All required configuration tables are defined
    3. Configuration values are of the correct types
    4. No common configuration mistakes are present
    
    HOW TO USE:
    1. Place this file in your server's lua/autorun/client or lua/autorun/server
    2. Start your server
    3. Check console output for validation results
    4. Fix any reported errors before deploying
    
    Or run manually in server console:
    > lua_run include("lua/tests/validate_config.lua")
    
================================================================================
]]--

print("\n" .. string.rep("=", 80))
print("CWRP Weapon Scanning System - Configuration Validator")
print(string.rep("=", 80) .. "\n")

local errors = {}
local warnings = {}
local function AddError(msg) table.insert(errors, msg) end
local function AddWarning(msg) table.insert(warnings, msg) end

-- Test 1: Check if configuration file is loaded
print("[1/8] Checking if configuration is loaded...")
if not ENABLE_SERVER_CONSOLE_LOGGING then
    AddWarning("ENABLE_SERVER_CONSOLE_LOGGING not defined (may not be loaded yet)")
else
    print("  ✓ Configuration appears to be loaded")
end

-- Test 2: Validate required tables exist
print("\n[2/8] Checking required configuration tables...")
local requiredTables = {
    "WEAPON_SCANNER_JOB_BYPASS",
    "ITEM_DANGER_LEVELS",
    "ITEM_JOB_EXCEPTIONS",
    "WEAPON_SCANNER_CONCEALMENT",
    "WEAPON_SCANNER_SYSTEMATIC",
    "WEAPON_SCANNER_MESSAGES",
    "SWEP_ALLOWED_TEAMS"
}

for _, tableName in ipairs(requiredTables) do
    if not _G[tableName] then
        AddError("Required table missing: " .. tableName)
    elseif type(_G[tableName]) ~= "table" then
        AddError(tableName .. " is not a table (found: " .. type(_G[tableName]) .. ")")
    else
        print("  ✓ " .. tableName .. " exists")
    end
end

-- Test 3: Validate danger levels use correct values
print("\n[3/8] Validating danger level values...")
if ITEM_DANGER_LEVELS then
    local validLevels = {["green"] = true, ["yellow"] = true, ["red"] = true}
    for itemClass, level in pairs(ITEM_DANGER_LEVELS) do
        if type(level) ~= "string" then
            AddError("ITEM_DANGER_LEVELS['" .. itemClass .. "'] is not a string")
        elseif not validLevels[level] then
            AddError("ITEM_DANGER_LEVELS['" .. itemClass .. "'] has invalid value: '" .. level .. "' (must be 'green', 'yellow', or 'red')")
        end
    end
    print("  ✓ Checked " .. table.Count(ITEM_DANGER_LEVELS) .. " danger level entries")
else
    AddError("ITEM_DANGER_LEVELS table not found")
end

-- Test 4: Validate item-job exceptions
print("\n[4/8] Validating item-job exceptions...")
if ITEM_JOB_EXCEPTIONS then
    local validPermissions = {["allowed"] = true, ["green"] = true, ["yellow"] = true, ["red"] = true}
    local exceptionCount = 0
    for itemClass, jobExceptions in pairs(ITEM_JOB_EXCEPTIONS) do
        if type(jobExceptions) == "table" then
            for jobID, permission in pairs(jobExceptions) do
                exceptionCount = exceptionCount + 1
                if type(permission) ~= "string" then
                    AddError("ITEM_JOB_EXCEPTIONS['" .. itemClass .. "'][" .. tostring(jobID) .. "] is not a string")
                elseif not validPermissions[permission] then
                    AddError("ITEM_JOB_EXCEPTIONS['" .. itemClass .. "'][" .. tostring(jobID) .. "] has invalid value: '" .. permission .. "'")
                end
            end
        else
            AddWarning("ITEM_JOB_EXCEPTIONS['" .. itemClass .. "'] is not a table")
        end
    end
    print("  ✓ Checked " .. exceptionCount .. " job exception entries")
else
    AddError("ITEM_JOB_EXCEPTIONS table not found")
end

-- Test 5: Validate concealment configuration
print("\n[5/8] Validating concealment configuration...")
if WEAPON_SCANNER_CONCEALMENT then
    if type(WEAPON_SCANNER_CONCEALMENT.enabled) ~= "boolean" then
        AddError("WEAPON_SCANNER_CONCEALMENT.enabled must be true or false")
    end
    if WEAPON_SCANNER_CONCEALMENT.maxConcealedSlots and type(WEAPON_SCANNER_CONCEALMENT.maxConcealedSlots) ~= "number" then
        AddError("WEAPON_SCANNER_CONCEALMENT.maxConcealedSlots must be a number")
    end
    if WEAPON_SCANNER_CONCEALMENT.concealTime and type(WEAPON_SCANNER_CONCEALMENT.concealTime) ~= "number" then
        AddError("WEAPON_SCANNER_CONCEALMENT.concealTime must be a number")
    end
    if WEAPON_SCANNER_CONCEALMENT.unconcealableItems and type(WEAPON_SCANNER_CONCEALMENT.unconcealableItems) ~= "table" then
        AddError("WEAPON_SCANNER_CONCEALMENT.unconcealableItems must be a table")
    end
    print("  ✓ Concealment configuration structure is valid")
else
    AddError("WEAPON_SCANNER_CONCEALMENT table not found")
end

-- Test 6: Validate systematic scanning configuration
print("\n[6/8] Validating systematic scanning configuration...")
if WEAPON_SCANNER_SYSTEMATIC then
    if type(WEAPON_SCANNER_SYSTEMATIC.enabled) ~= "boolean" then
        AddError("WEAPON_SCANNER_SYSTEMATIC.enabled must be true or false")
    end
    if WEAPON_SCANNER_SYSTEMATIC.slotDelay and type(WEAPON_SCANNER_SYSTEMATIC.slotDelay) ~= "number" then
        AddError("WEAPON_SCANNER_SYSTEMATIC.slotDelay must be a number")
    end
    if WEAPON_SCANNER_SYSTEMATIC.showProgress and type(WEAPON_SCANNER_SYSTEMATIC.showProgress) ~= "boolean" then
        AddError("WEAPON_SCANNER_SYSTEMATIC.showProgress must be true or false")
    end
    print("  ✓ Systematic scanning configuration structure is valid")
else
    AddError("WEAPON_SCANNER_SYSTEMATIC table not found")
end

-- Test 7: Validate messages configuration
print("\n[7/8] Validating messages configuration...")
if WEAPON_SCANNER_MESSAGES then
    local requiredMessages = {
        "scanStart", "scanComplete", "noWeapons",
        "allowedHeader", "dangerLevelRed", "dangerLevelYellow", "dangerLevelGreen",
        "jobBypass", "dangerAlert", "restrictedAlert", "infoClean", "infoItems"
    }
    for _, msgKey in ipairs(requiredMessages) do
        if not WEAPON_SCANNER_MESSAGES[msgKey] then
            AddWarning("WEAPON_SCANNER_MESSAGES." .. msgKey .. " is not defined")
        elseif type(WEAPON_SCANNER_MESSAGES[msgKey]) ~= "string" then
            AddError("WEAPON_SCANNER_MESSAGES." .. msgKey .. " must be a string")
        end
    end
    print("  ✓ Messages configuration structure is valid")
else
    AddError("WEAPON_SCANNER_MESSAGES table not found")
end

-- Test 8: Validate SWEP permissions
print("\n[8/8] Validating SWEP team permissions...")
if SWEP_ALLOWED_TEAMS then
    local expectedSWEPs = {"weapon_scanner", "weapon_confiscator", "weapon_drop"}
    for _, swepName in ipairs(expectedSWEPs) do
        if not SWEP_ALLOWED_TEAMS[swepName] then
            AddWarning("SWEP_ALLOWED_TEAMS['" .. swepName .. "'] is not defined")
        elseif type(SWEP_ALLOWED_TEAMS[swepName]) ~= "table" then
            AddError("SWEP_ALLOWED_TEAMS['" .. swepName .. "'] must be a table")
        elseif table.Count(SWEP_ALLOWED_TEAMS[swepName]) == 0 then
            AddWarning("SWEP_ALLOWED_TEAMS['" .. swepName .. "'] is empty (no teams can use this SWEP)")
        end
    end
    print("  ✓ SWEP permissions structure is valid")
else
    AddError("SWEP_ALLOWED_TEAMS table not found")
end

-- Print results
print("\n" .. string.rep("=", 80))
print("VALIDATION RESULTS")
print(string.rep("=", 80))

if #errors > 0 then
    print("\n❌ ERRORS FOUND (" .. #errors .. "):")
    for i, err in ipairs(errors) do
        print("  " .. i .. ". " .. err)
    end
end

if #warnings > 0 then
    print("\n⚠  WARNINGS (" .. #warnings .. "):")
    for i, warn in ipairs(warnings) do
        print("  " .. i .. ". " .. warn)
    end
end

if #errors == 0 and #warnings == 0 then
    print("\n✓✓✓ ALL VALIDATION CHECKS PASSED! ✓✓✓")
    print("Your configuration is valid and ready to use.")
elseif #errors == 0 then
    print("\n✓ Configuration is valid (with " .. #warnings .. " warning(s))")
    print("Warnings are non-critical but should be reviewed.")
else
    print("\n❌ Configuration has " .. #errors .. " error(s) that must be fixed!")
    print("Please review and correct the errors above.")
end

print("\n" .. string.rep("=", 80) .. "\n")

return {errors = errors, warnings = warnings, success = (#errors == 0)}
