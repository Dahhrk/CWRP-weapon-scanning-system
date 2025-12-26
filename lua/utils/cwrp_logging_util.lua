-- Centralized Logging Utility for Billy's Logs Integration

function CWRP_LogAction(moduleName, description, data)
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