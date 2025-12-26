-- Weapon Drop SWEP for Clone Wars Roleplay

AddCSLuaFile()

SWEP.PrintName = "Weapon Dropper"
SWEP.Author = "Dahhrk"
SWEP.Spawnable = true
SWEP.AdminOnly = false

function SWEP:Deploy()
    if CLIENT then return end
    
    local ply = self:GetOwner()
    if not IsValid(ply) then return end
    
    -- Check team permission
    if not CWRP_CheckTeamPermission(ply, "weapon_drop") then
        local teamName = team.GetName(ply:Team())
        ply:ChatPrint("[SWEP RESTRICTION]: You are not authorized to use the Weapon Dropper SWEP.")
        
        -- Log unauthorized attempt
        CWRP_LogAction("SWEP RESTRICTION", 
            string.format("Player %s (SteamID: %s) tried to deploy Weapon Dropper SWEP (Team: %s)", 
                ply:Nick(), ply:SteamID(), teamName))
        
        -- Remove the SWEP from player
        timer.Simple(SWEP_STRIP_DELAY or 0.1, function()
            if IsValid(ply) and IsValid(self) then
                ply:StripWeapon("weapon_drop")
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
    if not CWRP_CheckTeamPermission(ply, "weapon_drop") then
        local teamName = team.GetName(ply:Team())
        ply:ChatPrint("[SWEP RESTRICTION]: You are not authorized to use the Weapon Dropper SWEP.")
        
        -- Log unauthorized usage attempt
        CWRP_LogAction("SWEP RESTRICTION", 
            string.format("Player %s (SteamID: %s) tried to use Weapon Dropper SWEP (Team: %s)", 
                ply:Nick(), ply:SteamID(), teamName))
        
        return
    end
    
    local weapon = ply:GetActiveWeapon()

    if not IsValid(weapon) then
        ply:ChatPrint("No active weapon to drop.")
        return
    end

    ply:DropWeapon(weapon)
    hook.Run("CWRP_WeaponDropped", ply, weapon:GetClass())
end