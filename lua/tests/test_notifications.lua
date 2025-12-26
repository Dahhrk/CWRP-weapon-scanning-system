--[[
================================================================================
    CWRP WEAPON SCANNING SYSTEM - NOTIFICATION FORMAT TEST
================================================================================
    
    This script tests that notification messages use dynamic player names
    and include proper item details as specified in the requirements.
    
    HOW TO USE:
    Run in server console:
    > lua_run include("lua/tests/test_notifications.lua")
    
================================================================================
]]--

print("\n" .. string.rep("=", 80))
print("CWRP Weapon Scanning System - Notification Format Test")
print(string.rep("=", 80) .. "\n")

local errors = {}
local function AddError(msg) table.insert(errors, msg) end

-- Test 1: Check that new notification messages exist
print("[1/4] Checking new notification message formats...")
if not WEAPON_SCANNER_MESSAGES then
    AddError("WEAPON_SCANNER_MESSAGES table not found")
else
    -- Check for new message fields
    local requiredNewMessages = {
        "dangerAlert",
        "restrictedAlert",
        "infoClean",
        "infoItems"
    }
    
    for _, msgKey in ipairs(requiredNewMessages) do
        if not WEAPON_SCANNER_MESSAGES[msgKey] then
            AddError("Missing required message: WEAPON_SCANNER_MESSAGES." .. msgKey)
        else
            print("  ✓ " .. msgKey .. " = " .. WEAPON_SCANNER_MESSAGES[msgKey])
        end
    end
end

-- Test 2: Validate dangerAlert format has 3 placeholders
print("\n[2/4] Validating dangerAlert message format...")
if WEAPON_SCANNER_MESSAGES and WEAPON_SCANNER_MESSAGES.dangerAlert then
    local msg = WEAPON_SCANNER_MESSAGES.dangerAlert
    local _, count = msg:gsub("%%s", "")
    
    if count ~= 3 then
        AddError("dangerAlert should have 3 %s placeholders (scanner, item, target), found: " .. count)
    else
        print("  ✓ dangerAlert has correct format with 3 placeholders")
        
        -- Test example formatting
        local testMsg = string.format(msg, "JohnDoe", "weapon_lightsaber", "JaneSmith")
        print("  Example: " .. testMsg)
        
        if not testMsg:find("JohnDoe") then
            AddError("Scanner name not found in formatted message")
        end
        if not testMsg:find("weapon_lightsaber") then
            AddError("Item name not found in formatted message")
        end
        if not testMsg:find("JaneSmith") then
            AddError("Target name not found in formatted message")
        end
    end
end

-- Test 3: Validate restrictedAlert format has 3 placeholders
print("\n[3/4] Validating restrictedAlert message format...")
if WEAPON_SCANNER_MESSAGES and WEAPON_SCANNER_MESSAGES.restrictedAlert then
    local msg = WEAPON_SCANNER_MESSAGES.restrictedAlert
    local _, count = msg:gsub("%%s", "")
    
    if count ~= 3 then
        AddError("restrictedAlert should have 3 %s placeholders (scanner, item, target), found: " .. count)
    else
        print("  ✓ restrictedAlert has correct format with 3 placeholders")
        
        -- Test example formatting
        local testMsg = string.format(msg, "GuardName", "drug_pouch", "PlayerName")
        print("  Example: " .. testMsg)
        
        if not testMsg:find("GuardName") then
            AddError("Scanner name not found in formatted message")
        end
        if not testMsg:find("drug_pouch") then
            AddError("Item name not found in formatted message")
        end
        if not testMsg:find("PlayerName") then
            AddError("Target name not found in formatted message")
        end
    end
end

-- Test 4: Validate info messages
print("\n[4/4] Validating info message formats...")
if WEAPON_SCANNER_MESSAGES then
    -- Test infoClean
    if WEAPON_SCANNER_MESSAGES.infoClean then
        local msg = WEAPON_SCANNER_MESSAGES.infoClean
        local _, count = msg:gsub("%%s", "")
        
        if count ~= 1 then
            AddError("infoClean should have 1 %s placeholder (scanner name), found: " .. count)
        else
            print("  ✓ infoClean has correct format with 1 placeholder")
            local testMsg = string.format(msg, "ScannerName")
            print("    Example: " .. testMsg)
        end
    end
    
    -- Test infoItems
    if WEAPON_SCANNER_MESSAGES.infoItems then
        local msg = WEAPON_SCANNER_MESSAGES.infoItems
        local sCount = select(2, msg:gsub("%%s", ""))
        local dCount = select(2, msg:gsub("%%d", ""))
        
        if sCount ~= 1 or dCount ~= 1 then
            AddError("infoItems should have 1 %s (scanner) and 1 %d (item count) placeholder, found: " .. sCount .. " %s and " .. dCount .. " %d")
        else
            print("  ✓ infoItems has correct format with 2 placeholders")
            local testMsg = string.format(msg, "ScannerName", 5)
            print("    Example: " .. testMsg)
        end
    end
end

-- Print results
print("\n" .. string.rep("=", 80))
print("TEST RESULTS")
print(string.rep("=", 80))

if #errors == 0 then
    print("\n✓✓✓ ALL NOTIFICATION FORMAT TESTS PASSED! ✓✓✓")
    print("Notifications use dynamic player names and include item details.")
else
    print("\n❌ TESTS FAILED (" .. #errors .. " errors):")
    for i, err in ipairs(errors) do
        print("  " .. i .. ". " .. err)
    end
end

print("\n" .. string.rep("=", 80) .. "\n")

return {errors = errors, success = (#errors == 0)}
