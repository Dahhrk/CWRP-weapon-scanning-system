-- Weapon Scanner SWEP for Clone Wars Roleplay

AddCSLuaFile()

SWEP.PrintName = "Weapon Scanner"
SWEP.Author = "Dahhrk"
SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary.Automatic = false
SWEP.Secondary.Automatic = false

function SWEP:PrimaryAttack()
    if CLIENT then return end

    local ply = self:GetOwner()
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