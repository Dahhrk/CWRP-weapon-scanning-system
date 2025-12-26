-- Centralized Logging Utility for Billy's Logs Integration

function CWRP_LogAction(moduleName, description, data)
    -- Console logging
    if ENABLE_SERVER_CONSOLE_LOGGING then
        local logMessage = string.format("[%s] %s", moduleName, description)
        
        -- Add additional data to console log
        if data and type(data) == "table" then
            for key, value in pairs(data) do
                logMessage = logMessage .. string.format(" | %s: %s", tostring(key), tostring(value))
            end
        end
        
        print(logMessage)
    end
    
    -- Billy's Logs integration
    if bLogs then
        local logMessage = string.format("%s: %s", moduleName, description)

        -- Add additional data to the log
        if data and type(data) == "table" then
            for key, value in pairs(data) do
                logMessage = string.format("%s | %s: %s", logMessage, tostring(key), tostring(value))
            end
        end

        -- Log the message to Billy's Logs
        bLogs:Log({ module = moduleName, log = logMessage })
    end
end

-- Enhanced logging for scan results
function CWRP_LogScanResult(scanner, target, scanData)
    local logDetails = {
        scanner = scanner:Nick(),
        scannerSteamID = scanner:SteamID(),
        target = target:Nick(),
        targetSteamID = target:SteamID(),
        targetTeam = team.GetName(target:Team())
    }
    
    -- Add scan data details
    if scanData then
        if scanData.redItems and #scanData.redItems > 0 then
            logDetails.highDangerItems = table.concat(scanData.redItems, ", ")
        end
        if scanData.yellowItems and #scanData.yellowItems > 0 then
            logDetails.questionableItems = table.concat(scanData.yellowItems, ", ")
        end
        if scanData.greenItems and #scanData.greenItems > 0 then
            logDetails.lowThreatItems = table.concat(scanData.greenItems, ", ")
        end
        if scanData.allowedItems and #scanData.allowedItems > 0 then
            logDetails.allowedItems = table.concat(scanData.allowedItems, ", ")
        end
    end
    
    local description = string.format(
        "%s scanned %s (Team: %s)",
        scanner:Nick(), target:Nick(), team.GetName(target:Team())
    )
    
    CWRP_LogAction("WEAPON SCAN", description, logDetails)
end

-- Logging for confiscation with detailed item info
function CWRP_LogConfiscation(confiscator, target, confiscatedWeapons)
    local logDetails = {
        confiscator = confiscator:Nick(),
        confiscatorSteamID = confiscator:SteamID(),
        target = target:Nick(),
        targetSteamID = target:SteamID(),
        confiscatedItems = table.concat(confiscatedWeapons, ", "),
        itemCount = #confiscatedWeapons
    }
    
    local description = string.format(
        "%s confiscated %d items from %s",
        confiscator:Nick(), #confiscatedWeapons, target:Nick()
    )
    
    CWRP_LogAction("CONFISCATION", description, logDetails)
end
