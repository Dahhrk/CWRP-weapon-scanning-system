-- Weapon Scanner SWEP for Clone Wars Roleplay

AddCSLuaFile()

SWEP.PrintName = "Weapon Scanner"
SWEP.Author = "Dahhrk"
SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary.Automatic = false
SWEP.Secondary.Automatic = false

function SWEP:Deploy()
    if CLIENT then return end
    
    local ply = self:GetOwner()
    if not IsValid(ply) then return end
    
    -- Check team permission
    if not CWRP_CheckTeamPermission(ply, "weapon_scanner") then
        local teamName = team.GetName(ply:Team())
        ply:ChatPrint("[SWEP RESTRICTION]: You are not authorized to use the Weapon Scanner SWEP.")
        
        -- Log unauthorized attempt
        CWRP_LogAction("SWEP RESTRICTION", 
            string.format("Player %s (SteamID: %s) tried to deploy Weapon Scanner SWEP (Team: %s)", 
                ply:Nick(), ply:SteamID(), teamName))
        
        -- Remove the SWEP from player
        timer.Simple(SWEP_STRIP_DELAY or 0.1, function()
            if IsValid(ply) and IsValid(self) then
                ply:StripWeapon("weapon_scanner")
            end
        end)
        
        return false
    end
    
    return true
end

function SWEP:PrimaryAttack()
    if CLIENT then return end

    local ply = self:GetOwner()
    
    -- Check team permission before allowing usage
    if not CWRP_CheckTeamPermission(ply, "weapon_scanner") then
        local teamName = team.GetName(ply:Team())
        ply:ChatPrint("[SWEP RESTRICTION]: You are not authorized to use the Weapon Scanner SWEP.")
        
        -- Log unauthorized usage attempt
        CWRP_LogAction("SWEP RESTRICTION", 
            string.format("Player %s (SteamID: %s) tried to use Weapon Scanner SWEP (Team: %s)", 
                ply:Nick(), ply:SteamID(), teamName))
        
        return
    end
    
    local target = ply:GetEyeTrace().Entity

    if not IsValid(target) or not target:IsPlayer() then
        ply:ChatPrint("No player detected. Aim at a player to scan.")
        return
    end

    -- Check for job-based bypass (NEW FEATURE - replaces cloaking device)
    local targetTeam = target:Team()
    if WEAPON_SCANNER_JOB_BYPASS and WEAPON_SCANNER_JOB_BYPASS[targetTeam] then
        local bypassMsg = WEAPON_SCANNER_MESSAGES and WEAPON_SCANNER_MESSAGES.jobBypass or "This role cannot be scanned."
        ply:ChatPrint(bypassMsg)
        
        -- Log job bypass
        CWRP_LogAction("JOB BYPASS", 
            string.format("Player %s (Team: %s) bypassed scan by %s due to job-based bypass", 
                target:Nick(), team.GetName(targetTeam), ply:Nick()))
        
        return
    end
    
    -- Check if target has role bypass
    local targetRole = target:GetUserGroup()
    if WEAPON_SCANNER_ROLE_BYPASS and WEAPON_SCANNER_ROLE_BYPASS[targetRole] then
        ply:ChatPrint("Player " .. target:Nick() .. " has scanning immunity.")
        return
    end
    
    -- Check for stealth roles (DEPRECATED - kept for backwards compatibility)
    if WEAPON_SCANNER_STEALTH_ROLES and WEAPON_SCANNER_STEALTH_ROLES[targetRole] then
        local stealthMsg = WEAPON_SCANNER_MESSAGES and WEAPON_SCANNER_MESSAGES.stealthBypass or "Scan bypassed - Stealth technology detected."
        ply:ChatPrint(stealthMsg)
        return
    end
    
    -- Check for stealth teams (DEPRECATED - kept for backwards compatibility)
    if WEAPON_SCANNER_STEALTH_TEAMS and WEAPON_SCANNER_STEALTH_TEAMS[targetTeam] then
        local stealthMsg = WEAPON_SCANNER_MESSAGES and WEAPON_SCANNER_MESSAGES.stealthBypass or "Scan bypassed - Stealth technology detected."
        ply:ChatPrint(stealthMsg)
        return
    end
    
    -- Check if target is using cloaking device (DEPRECATED - kept for backwards compatibility)
    if target:HasWeapon("weapon_cloaking_device") then
        -- Log cloaking device usage
        CWRP_LogAction("CLOAKING DEVICE", 
            string.format("Player %s (SteamID: %s) used cloaking device to bypass scan by %s", 
                target:Nick(), target:SteamID(), ply:Nick()))
        
        ply:ChatPrint("Scan complete - Empty pockets detected.")
        return
    end
    
    -- Play scan sound if configured
    if WEAPON_SCANNER_MESSAGES and WEAPON_SCANNER_MESSAGES.playScanSound and WEAPON_SCANNER_MESSAGES.scanSound then
        ply:EmitSound(WEAPON_SCANNER_MESSAGES.scanSound)
    end

    -- Helper function to get danger level for an item
    local function GetDangerLevel(weaponClass, targetTeam)
        -- Check item-job exceptions first
        if ITEM_JOB_EXCEPTIONS and ITEM_JOB_EXCEPTIONS[weaponClass] then
            local exception = ITEM_JOB_EXCEPTIONS[weaponClass][targetTeam]
            if exception then
                if exception == "allowed" then
                    return "allowed"
                else
                    return exception -- "red", "yellow", or "green"
                end
            end
        end
        
        -- Check danger level configuration
        if ITEM_DANGER_LEVELS and ITEM_DANGER_LEVELS[weaponClass] then
            return ITEM_DANGER_LEVELS[weaponClass]
        end
        
        -- Check if in contraband list (backwards compatibility)
        if WEAPON_SCANNER_CONTRABAND then
            for _, contrabandWeapon in ipairs(WEAPON_SCANNER_CONTRABAND) do
                if weaponClass == contrabandWeapon then
                    return "red"
                end
            end
        end
        
        -- Check if in blacklist (backwards compatibility)
        if WEAPON_SCANNER_BLACKLIST then
            for _, blacklistedWeapon in ipairs(WEAPON_SCANNER_BLACKLIST) do
                if weaponClass == blacklistedWeapon then
                    return "yellow"
                end
            end
        end
        
        -- Check if in whitelist (backwards compatibility)
        if WEAPON_SCANNER_WHITELIST then
            for _, whitelistedWeapon in ipairs(WEAPON_SCANNER_WHITELIST) do
                if weaponClass == whitelistedWeapon then
                    return "green"
                end
            end
        end
        
        -- Default to yellow (questionable)
        return "yellow"
    end

    local scanResults = {}
    local redItems = {}
    local yellowItems = {}
    local greenItems = {}
    local allowedItems = {}
    local contrabandItems = {}
    
    -- Get target's concealed items (if concealment system is enabled)
    local concealedItems = {}
    if target.CWRP_ConcealedItems then
        concealedItems = target.CWRP_ConcealedItems
    end
    
    -- Systematic scan if enabled
    local systematic = WEAPON_SCANNER_SYSTEMATIC and WEAPON_SCANNER_SYSTEMATIC.enabled
    local slotDelay = (systematic and WEAPON_SCANNER_SYSTEMATIC.slotDelay) or 0
    
    local weapons = target:GetWeapons()
    local currentSlot = 0
    
    local function ScanSlot(index)
        if not IsValid(ply) or not IsValid(target) then return end
        
        -- Check distance if systematic scanning
        if systematic and WEAPON_SCANNER_SYSTEMATIC.maxScanDistance then
            local distance = ply:GetPos():Distance(target:GetPos())
            if distance > WEAPON_SCANNER_SYSTEMATIC.maxScanDistance then
                ply:ChatPrint("[SCAN CANCELLED] Target moved out of range.")
                return
            end
        end
        
        if index > #weapons then
            -- Scan complete - display results
            DisplayScanResults()
            return
        end
        
        local weapon = weapons[index]
        if IsValid(weapon) then
            local weaponClass = weapon:GetClass()
            
            -- Check if item is concealed
            local isConcealed = false
            for _, concealedItem in ipairs(concealedItems) do
                if concealedItem == weaponClass then
                    isConcealed = true
                    break
                end
            end
            
            if not isConcealed then
                table.insert(scanResults, weaponClass)
                
                local dangerLevel = GetDangerLevel(weaponClass, targetTeam)
                
                if dangerLevel == "allowed" then
                    table.insert(allowedItems, weaponClass)
                elseif dangerLevel == "red" then
                    table.insert(redItems, weaponClass)
                    table.insert(contrabandItems, weaponClass)
                elseif dangerLevel == "yellow" then
                    table.insert(yellowItems, weaponClass)
                elseif dangerLevel == "green" then
                    table.insert(greenItems, weaponClass)
                end
            end
        end
        
        -- Show progress if enabled
        if systematic and WEAPON_SCANNER_SYSTEMATIC.showProgress then
            ply:ChatPrint(string.format("[SCANNING] Slot %d/%d...", index, #weapons))
        end
        
        -- Schedule next slot
        if systematic and slotDelay > 0 then
            timer.Simple(slotDelay, function()
                ScanSlot(index + 1)
            end)
        else
            ScanSlot(index + 1)
        end
    end
    
    function DisplayScanResults()
        -- Display scan results with custom messages
        local scanStartMsg = WEAPON_SCANNER_MESSAGES and WEAPON_SCANNER_MESSAGES.scanStart or "[SCANNING...]"
        local scanCompleteMsg = WEAPON_SCANNER_MESSAGES and WEAPON_SCANNER_MESSAGES.scanComplete or "[SCAN COMPLETE]"
        
        ply:ChatPrint(scanStartMsg)
        ply:ChatPrint("=== Scan Results for " .. target:Nick() .. " ===")
        
        -- Alert for high-danger items if detected
        if #redItems > 0 then
            local contrabandMsg = WEAPON_SCANNER_MESSAGES and WEAPON_SCANNER_MESSAGES.contrabandDetected or "⚠ CRITICAL CONTRABAND DETECTED ⚠"
            ply:ChatPrint(contrabandMsg)
            
            -- Play contraband alert sound
            if WEAPON_SCANNER_CONTRABAND_ALERTS and WEAPON_SCANNER_CONTRABAND_ALERTS.playSound and WEAPON_SCANNER_CONTRABAND_ALERTS.soundEffect then
                ply:EmitSound(WEAPON_SCANNER_CONTRABAND_ALERTS.soundEffect)
            end
            
            -- Send real-time alerts to nearby guards
            local alertRadius = (WEAPON_SCANNER_CONTRABAND_ALERTS and WEAPON_SCANNER_CONTRABAND_ALERTS.alertRadius) or 500
            local alertTeams = (WEAPON_SCANNER_CONTRABAND_ALERTS and WEAPON_SCANNER_CONTRABAND_ALERTS.alertTeams) or {}
            
            for _, nearbyPly in ipairs(player.GetAll()) do
                if nearbyPly ~= ply and IsValid(nearbyPly) then
                    local distance = ply:GetPos():Distance(nearbyPly:GetPos())
                    
                    -- Check if player is in alert radius and on an alert team
                    local shouldAlert = distance <= alertRadius
                    if shouldAlert and #alertTeams > 0 then
                        shouldAlert = false
                        local nearbyTeam = nearbyPly:Team()
                        for _, alertTeam in ipairs(alertTeams) do
                            if nearbyTeam == alertTeam then
                                shouldAlert = true
                                break
                            end
                        end
                    end
                    
                    if shouldAlert then
                        -- Send detailed alert for each red item
                        for _, redItem in ipairs(redItems) do
                            local alertMsg = WEAPON_SCANNER_MESSAGES and WEAPON_SCANNER_MESSAGES.dangerAlert or "[ALERT] High-danger item detected: %s in %s's inventory!"
                            nearbyPly:ChatPrint(string.format(alertMsg, redItem, target:Nick()))
                        end
                        
                        if WEAPON_SCANNER_CONTRABAND_ALERTS and WEAPON_SCANNER_CONTRABAND_ALERTS.playSound and WEAPON_SCANNER_CONTRABAND_ALERTS.soundEffect then
                            nearbyPly:EmitSound(WEAPON_SCANNER_CONTRABAND_ALERTS.soundEffect)
                        end
                    end
                end
            end
        end
        
        -- Display red (high-danger) items
        if #redItems > 0 then
            local redHeader = WEAPON_SCANNER_MESSAGES and WEAPON_SCANNER_MESSAGES.dangerLevelRed or "HIGH-DANGER ITEMS:"
            ply:ChatPrint(redHeader)
            for _, weaponClass in ipairs(redItems) do
                ply:ChatPrint("  [⚠] " .. weaponClass)
            end
        end
        
        -- Display yellow (questionable) items
        if #yellowItems > 0 then
            local yellowHeader = WEAPON_SCANNER_MESSAGES and WEAPON_SCANNER_MESSAGES.dangerLevelYellow or "QUESTIONABLE ITEMS:"
            ply:ChatPrint(yellowHeader)
            for _, weaponClass in ipairs(yellowItems) do
                ply:ChatPrint("  [!] " .. weaponClass)
            end
        end
        
        -- Display green (low-threat) items
        if #greenItems > 0 then
            local greenHeader = WEAPON_SCANNER_MESSAGES and WEAPON_SCANNER_MESSAGES.dangerLevelGreen or "LOW-THREAT ITEMS:"
            ply:ChatPrint(greenHeader)
            for _, weaponClass in ipairs(greenItems) do
                ply:ChatPrint("  [✓] " .. weaponClass)
            end
        end
        
        -- Display allowed items
        if #allowedItems > 0 then
            local allowedHeader = WEAPON_SCANNER_MESSAGES and WEAPON_SCANNER_MESSAGES.allowedHeader or "ALLOWED ITEMS:"
            ply:ChatPrint(allowedHeader)
            for _, weaponClass in ipairs(allowedItems) do
                ply:ChatPrint("  [✓] " .. weaponClass)
            end
        end
        
        if #scanResults == 0 then
            local noWeaponsMsg = WEAPON_SCANNER_MESSAGES and WEAPON_SCANNER_MESSAGES.noWeapons or "No weapons detected."
            ply:ChatPrint(noWeaponsMsg)
        end
        
        ply:ChatPrint(scanCompleteMsg)
        
        -- Admin logging
        local logDetails = {
            scanner = ply:Nick(),
            scannerSteamID = ply:SteamID(),
            target = target:Nick(),
            targetSteamID = target:SteamID(),
            targetTeam = team.GetName(targetTeam),
            redItems = table.concat(redItems, ", "),
            yellowItems = table.concat(yellowItems, ", "),
            greenItems = table.concat(greenItems, ", "),
            allowedItems = table.concat(allowedItems, ", "),
            totalItems = #scanResults
        }
        
        local logMsg = string.format(
            "[SCAN] Guard %s scanned %s (Team: %s) - Red: %d, Yellow: %d, Green: %d, Allowed: %d",
            ply:Nick(), target:Nick(), team.GetName(targetTeam),
            #redItems, #yellowItems, #greenItems, #allowedItems
        )
        
        CWRP_LogAction("WEAPON SCAN", logMsg, logDetails)

        hook.Run("CWRP_PlayerScanned", ply, target, {
            detectedWeapons = scanResults,
            redItems = redItems,
            yellowItems = yellowItems,
            greenItems = greenItems,
            allowedItems = allowedItems,
            contrabandItems = contrabandItems
        })
    end
    
    -- Start scanning
    if systematic and slotDelay > 0 and #weapons > 0 then
        ply:ChatPrint("[SYSTEMATIC SCAN] Starting slot-by-slot scan...")
        ScanSlot(1)
    else
        -- Immediate scan
        for i = 1, #weapons do
            ScanSlot(i)
        end
    end
end