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
    if ConfiscatedWeapons[steamID] then
        for _, weapon in ipairs(ConfiscatedWeapons[steamID]) do
            caller:Give(weapon)
        end
        ConfiscatedWeapons[steamID] = nil
    else
        caller:ChatPrint("You have no confiscated weapons.")
    end
end

scripted_ents.Register(ENT, "weapon_retrieval_npc")