-- Cloaking Device SWEP for Clone Wars Roleplay
-- DEPRECATED: This SWEP has been replaced with job-based bypass functionality
-- Jobs should now define bypassScan = true in WEAPON_SCANNER_JOB_BYPASS configuration
-- This file is kept for backwards compatibility only

AddCSLuaFile()

SWEP.PrintName = "Cloaking Device (DEPRECATED)"
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
    
    -- Show deprecation warning
    ply:ChatPrint("===========================================")
    ply:ChatPrint("[DEPRECATION WARNING]")
    ply:ChatPrint("Cloaking Device SWEP is deprecated!")
    ply:ChatPrint("Use job-based bypass instead.")
    ply:ChatPrint("Configure WEAPON_SCANNER_JOB_BYPASS in config.")
    ply:ChatPrint("===========================================")
    
    -- Check team permission if configured
    if SWEP_ALLOWED_TEAMS and SWEP_ALLOWED_TEAMS["weapon_bypass_scanning_swep"] and #SWEP_ALLOWED_TEAMS["weapon_bypass_scanning_swep"] > 0 then
        if not CWRP_CheckTeamPermission(ply, "weapon_bypass_scanning_swep") then
            local teamName = team.GetName(ply:Team())
            ply:ChatPrint("[SWEP RESTRICTION]: You are not authorized to use the Cloaking Device SWEP.")
            
            -- Log unauthorized attempt
            CWRP_LogAction("SWEP RESTRICTION", 
                string.format("Player %s (SteamID: %s) tried to deploy Cloaking Device SWEP (Team: %s)", 
                    ply:Nick(), ply:SteamID(), teamName))
            
            -- Remove the SWEP from player
            timer.Simple(SWEP_STRIP_DELAY or 0.1, function()
                if IsValid(ply) and IsValid(self) then
                    ply:StripWeapon("weapon_bypass_scanning_swep")
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
