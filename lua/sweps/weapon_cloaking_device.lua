-- Cloaking Device SWEP for Clone Wars Roleplay
-- Allows stealth roles to bypass scanner detection

AddCSLuaFile()

SWEP.PrintName = "Cloaking Device"
SWEP.Author = "Dahhrk"
SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary.Automatic = false
SWEP.Secondary.Automatic = false

SWEP.ViewModel = "models/weapons/v_hands.mdl"
SWEP.WorldModel = ""

-- Cloaking Device Configuration
SWEP.CloakingActive = false

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:Deploy()
    if CLIENT then return end
    
    local ply = self:GetOwner()
    if not IsValid(ply) then return end
    
    -- Check team permission if configured
    if SWEP_ALLOWED_TEAMS and SWEP_ALLOWED_TEAMS["weapon_cloaking_device"] and #SWEP_ALLOWED_TEAMS["weapon_cloaking_device"] > 0 then
        if not CWRP_CheckTeamPermission(ply, "weapon_cloaking_device") then
            local teamName = team.GetName(ply:Team())
            ply:ChatPrint("[SWEP RESTRICTION]: You are not authorized to use the Cloaking Device SWEP.")
            
            -- Log unauthorized attempt
            CWRP_LogAction("SWEP RESTRICTION", 
                string.format("Player %s (SteamID: %s) tried to deploy Cloaking Device SWEP (Team: %s)", 
                    ply:Nick(), ply:SteamID(), teamName))
            
            -- Remove the SWEP from player
            timer.Simple(SWEP_STRIP_DELAY or 0.1, function()
                if IsValid(ply) and IsValid(self) then
                    ply:StripWeapon("weapon_cloaking_device")
                end
            end)
            
            return false
        end
    end
    
    ply:ChatPrint("[Cloaking Device] Deployed - Your weapons are now hidden from scanners.")
    ply:ChatPrint("[Cloaking Device] While equipped, scans will show 'Empty pockets'.")
    
    return true
end

function SWEP:Holster()
    if CLIENT then return end
    
    local ply = self:GetOwner()
    if IsValid(ply) then
        ply:ChatPrint("[Cloaking Device] Holstered - Scanner protection deactivated.")
    end
    
    return true
end

function SWEP:PrimaryAttack()
    -- No primary attack functionality
    -- The cloaking effect is passive while equipped
end

function SWEP:SecondaryAttack()
    -- No secondary attack functionality
end

function SWEP:Think()
    -- Passive cloaking while equipped
end

-- Custom hook for integration with weapon scanner
hook.Add("CWRP_PlayerScanned", "CloakingDevice_SpoofScan", function(scanner, target, scanData)
    if IsValid(target) and target:HasWeapon("weapon_cloaking_device") then
        -- The scan is already spoofed in weapon_scanner.lua
        -- This hook can be used for additional logging if needed
        CWRP_LogAction("CLOAKING DEVICE", 
            string.format("Player %s (SteamID: %s) used cloaking device to bypass scan by %s", 
                target:Nick(), target:SteamID(), scanner:Nick()))
    end
end)
