-- Weapon Confiscator SWEP for Clone Wars Roleplay

AddCSLuaFile()

SWEP.PrintName = "Weapon Confiscator"
SWEP.Author = "Dahhrk"
SWEP.Spawnable = true
SWEP.AdminOnly = true

function SWEP:PrimaryAttack()
    if CLIENT then return end

    local ply = self:GetOwner()
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