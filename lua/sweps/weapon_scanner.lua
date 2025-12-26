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

    -- Check if target has role bypass
    local targetRole = target:GetUserGroup()
    if WEAPON_SCANNER_ROLE_BYPASS and WEAPON_SCANNER_ROLE_BYPASS[targetRole] then
        ply:ChatPrint("Player " .. target:Nick() .. " has scanning immunity.")
        return
    end
    
    -- Check for stealth roles
    if WEAPON_SCANNER_STEALTH_ROLES and WEAPON_SCANNER_STEALTH_ROLES[targetRole] then
        local stealthMsg = WEAPON_SCANNER_MESSAGES and WEAPON_SCANNER_MESSAGES.stealthBypass or "Scan bypassed - Stealth technology detected."
        ply:ChatPrint(stealthMsg)
        return
    end
    
    -- Check for stealth teams
    local targetTeam = target:Team()
    if WEAPON_SCANNER_STEALTH_TEAMS and WEAPON_SCANNER_STEALTH_TEAMS[targetTeam] then
        local stealthMsg = WEAPON_SCANNER_MESSAGES and WEAPON_SCANNER_MESSAGES.stealthBypass or "Scan bypassed - Stealth technology detected."
        ply:ChatPrint(stealthMsg)
        return
    end
    
    -- Check if target is using cloaking device
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

    local scanResults = {}
    local blacklistedItems = {}
    local allowedItems = {}
    local contrabandItems = {}
    local contrabandLookup = {} -- For O(1) lookup
    
    for _, weapon in ipairs(target:GetWeapons()) do
        local weaponClass = weapon:GetClass()
        table.insert(scanResults, weaponClass)
        
        -- Check if weapon is contraband first
        local isContraband = false
        if WEAPON_SCANNER_CONTRABAND then
            for _, contrabandWeapon in ipairs(WEAPON_SCANNER_CONTRABAND) do
                if weaponClass == contrabandWeapon then
                    isContraband = true
                    contrabandLookup[weaponClass] = true
                    break
                end
            end
        end
        
        -- Check if weapon is blacklisted
        local isBlacklisted = false
        if WEAPON_SCANNER_BLACKLIST then
            for _, blacklistedWeapon in ipairs(WEAPON_SCANNER_BLACKLIST) do
                if weaponClass == blacklistedWeapon then
                    isBlacklisted = true
                    break
                end
            end
        end
        
        -- Categorize weapon
        if isContraband then
            table.insert(contrabandItems, weaponClass)
            table.insert(blacklistedItems, weaponClass)
        elseif isBlacklisted then
            table.insert(blacklistedItems, weaponClass)
        else
            table.insert(allowedItems, weaponClass)
        end
    end
    
    -- Display scan results with custom messages
    local scanStartMsg = WEAPON_SCANNER_MESSAGES and WEAPON_SCANNER_MESSAGES.scanStart or "[SCANNING...]"
    local scanCompleteMsg = WEAPON_SCANNER_MESSAGES and WEAPON_SCANNER_MESSAGES.scanComplete or "[SCAN COMPLETE]"
    
    ply:ChatPrint(scanStartMsg)
    ply:ChatPrint("=== Scan Results for " .. target:Nick() .. " ===")
    
    -- Alert for contraband if detected
    if #contrabandItems > 0 and WEAPON_SCANNER_CONTRABAND_ALERTS and WEAPON_SCANNER_CONTRABAND_ALERTS.enabled then
        local contrabandMsg = WEAPON_SCANNER_MESSAGES and WEAPON_SCANNER_MESSAGES.contrabandDetected or "⚠ CRITICAL CONTRABAND DETECTED ⚠"
        ply:ChatPrint(contrabandMsg)
        
        -- Play contraband alert sound
        if WEAPON_SCANNER_CONTRABAND_ALERTS.playSound and WEAPON_SCANNER_CONTRABAND_ALERTS.soundEffect then
            ply:EmitSound(WEAPON_SCANNER_CONTRABAND_ALERTS.soundEffect)
        end
        
        -- Alert nearby authorized players
        local alertRadius = WEAPON_SCANNER_CONTRABAND_ALERTS.alertRadius or 500
        local alertTeams = WEAPON_SCANNER_CONTRABAND_ALERTS.alertTeams or {}
        
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
                    nearbyPly:ChatPrint("⚠ [ALERT] Contraband detected on " .. target:Nick() .. " by " .. ply:Nick())
                    if WEAPON_SCANNER_CONTRABAND_ALERTS.playSound and WEAPON_SCANNER_CONTRABAND_ALERTS.soundEffect then
                        nearbyPly:EmitSound(WEAPON_SCANNER_CONTRABAND_ALERTS.soundEffect)
                    end
                end
            end
        end
    end
    
    if #blacklistedItems > 0 then
        local blacklistedHeader = WEAPON_SCANNER_MESSAGES and WEAPON_SCANNER_MESSAGES.blacklistedHeader or "BLACKLISTED ITEMS:"
        ply:ChatPrint(blacklistedHeader)
        for _, weaponClass in ipairs(blacklistedItems) do
            local prefix = "[!]"
            -- Mark contraband with special indicator using lookup table
            if contrabandLookup[weaponClass] then
                prefix = "[⚠]"
            end
            ply:ChatPrint("  " .. prefix .. " " .. weaponClass)
        end
    end
    
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

    hook.Run("CWRP_PlayerScanned", ply, target, {
        detectedWeapons = scanResults,
        blacklistedItems = blacklistedItems,
        allowedItems = allowedItems,
        contrabandItems = contrabandItems
    })
end