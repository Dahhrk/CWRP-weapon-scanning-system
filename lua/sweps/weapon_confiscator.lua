-- Weapon Confiscator SWEP for Clone Wars Roleplay

AddCSLuaFile()

SWEP.PrintName = "Weapon Confiscator"
SWEP.Author = "Dahhrk"
SWEP.Spawnable = true
SWEP.AdminOnly = true

function SWEP:Deploy()
    if CLIENT then return end
    
    local ply = self:GetOwner()
    if not IsValid(ply) then return end
    
    -- Check team permission
    if not CWRP_CheckTeamPermission(ply, "weapon_confiscator") then
        local teamName = team.GetName(ply:Team())
        ply:ChatPrint("[SWEP RESTRICTION]: You are not authorized to use the Weapon Confiscator SWEP.")
        
        -- Log unauthorized attempt
        CWRP_LogAction("SWEP RESTRICTION", 
            string.format("Player %s (SteamID: %s) tried to deploy Weapon Confiscator SWEP (Team: %s)", 
                ply:Nick(), ply:SteamID(), teamName))
        
        -- Remove the SWEP from player
        timer.Simple(0.1, function()
            if IsValid(ply) and IsValid(self) then
                ply:StripWeapon("weapon_confiscator")
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
    if not CWRP_CheckTeamPermission(ply, "weapon_confiscator") then
        local teamName = team.GetName(ply:Team())
        ply:ChatPrint("[SWEP RESTRICTION]: You are not authorized to use the Weapon Confiscator SWEP.")
        
        -- Log unauthorized usage attempt
        CWRP_LogAction("SWEP RESTRICTION", 
            string.format("Player %s (SteamID: %s) tried to use Weapon Confiscator SWEP (Team: %s)", 
                ply:Nick(), ply:SteamID(), teamName))
        
        return
    end
    
    local target = ply:GetEyeTrace().Entity

    if not IsValid(target) or not target:IsPlayer() then
        ply:ChatPrint("No player detected. Aim at a player to confiscate weapons.")
        return
    end

    local confiscatedWeapons = {}
    for _, weapon in ipairs(target:GetWeapons()) do
        table.insert(confiscatedWeapons, weapon:GetClass())
        target:StripWeapon(weapon:GetClass())
    end

    -- Store confiscation data with confiscator information
    ConfiscatedWeapons[target:SteamID()] = {
        weapons = confiscatedWeapons,
        confiscatorSteamID = ply:SteamID(),
        confiscatorName = ply:Nick(),
        timestamp = os.time()
    }
    
    -- Save to disk
    if CWRP_SaveConfiscatedWeapons then
        CWRP_SaveConfiscatedWeapons()
    end

    hook.Run("CWRP_PlayerConfiscated", ply, target, confiscatedWeapons)
end