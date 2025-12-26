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
        timer.Simple(0.1, function()
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

    local scanResults = {}
    local blacklistedItems = {}
    local allowedItems = {}
    
    for _, weapon in ipairs(target:GetWeapons()) do
        local weaponClass = weapon:GetClass()
        table.insert(scanResults, weaponClass)
        
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
        if isBlacklisted then
            table.insert(blacklistedItems, weaponClass)
        else
            table.insert(allowedItems, weaponClass)
        end
    end
    
    -- Display scan results
    ply:ChatPrint("=== Scan Results for " .. target:Nick() .. " ===")
    
    if #blacklistedItems > 0 then
        ply:ChatPrint("BLACKLISTED ITEMS:")
        for _, weaponClass in ipairs(blacklistedItems) do
            ply:ChatPrint("  [!] " .. weaponClass)
        end
    end
    
    if #allowedItems > 0 then
        ply:ChatPrint("ALLOWED ITEMS:")
        for _, weaponClass in ipairs(allowedItems) do
            ply:ChatPrint("  [✓] " .. weaponClass)
        end
    end
    
    if #scanResults == 0 then
        ply:ChatPrint("No weapons detected.")
    end

    hook.Run("CWRP_PlayerScanned", ply, target, {
        detectedWeapons = scanResults,
        blacklistedItems = blacklistedItems,
        allowedItems = allowedItems
    })
end