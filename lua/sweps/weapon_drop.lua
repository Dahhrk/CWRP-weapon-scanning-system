-- Weapon Drop SWEP for Clone Wars Roleplay

AddCSLuaFile()

SWEP.PrintName = "Weapon Dropper"
SWEP.Author = "Dahhrk"
SWEP.Spawnable = true
SWEP.AdminOnly = false

function SWEP:PrimaryAttack()
    if CLIENT then return end

    local ply = self:GetOwner()
    local weapon = ply:GetActiveWeapon()

    if not IsValid(weapon) then
        ply:ChatPrint("No active weapon to drop.")
        return
    end

    ply:DropWeapon(weapon)
    hook.Run("CWRP_WeaponDropped", ply, weapon:GetClass())
end