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

    local scanResults = {}
    for _, weapon in ipairs(target:GetWeapons()) do
        table.insert(scanResults, weapon:GetClass())
    end

    hook.Run("CWRP_PlayerScanned", ply, target, {
        detectedWeapons = scanResults
    })
end