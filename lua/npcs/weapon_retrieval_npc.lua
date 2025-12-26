-- Weapon Retrieval NPC for Clone Wars Roleplay

AddCSLuaFile()

local ENT = {}
ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.Model = "models/Humans/Group03/male_07.mdl"

function ENT:AcceptInput(name, caller)
    if not IsValid(caller) or not caller:IsPlayer() then
        return
    end

    local steamID = caller:SteamID()
    if ConfiscatedWeapons[steamID] and ConfiscatedWeapons[steamID].weapons then
        for _, weapon in ipairs(ConfiscatedWeapons[steamID].weapons) do
            caller:Give(weapon)
        end
        ConfiscatedWeapons[steamID] = nil
        
        -- Save changes to disk
        if CWRP_SaveConfiscatedWeapons then
            CWRP_SaveConfiscatedWeapons()
        end
    else
        caller:ChatPrint("You have no confiscated weapons.")
    end
end

scripted_ents.Register(ENT, "weapon_retrieval_npc")