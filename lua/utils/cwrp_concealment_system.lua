-- Concealment System for CWRP Weapon Scanner
-- Allows players to hide items during scans

if SERVER then
    -- Initialize concealed items table for each player
    hook.Add("PlayerInitialSpawn", "CWRP_InitConcealment", function(ply)
        ply.CWRP_ConcealedItems = {}
        ply.CWRP_ConcealmentInProgress = false
    end)
    
    -- Clean up on disconnect
    hook.Add("PlayerDisconnected", "CWRP_CleanupConcealment", function(ply)
        if ply.CWRP_ConcealedItems then
            ply.CWRP_ConcealedItems = nil
        end
        ply.CWRP_ConcealmentInProgress = nil
    end)
    
    -- Network strings for concealment UI
    util.AddNetworkString("CWRP_StartConcealment")
    util.AddNetworkString("CWRP_ConcealmentProgress")
    util.AddNetworkString("CWRP_ConcealmentComplete")
    util.AddNetworkString("CWRP_ConcealmentFailed")
    util.AddNetworkString("CWRP_RevealItem")
    
    -- Function to check if an item can be concealed
    function CWRP_CanConcealItem(weaponClass)
        if not WEAPON_SCANNER_CONCEALMENT or not WEAPON_SCANNER_CONCEALMENT.enabled then
            return false
        end
        
        -- Check if item is in the unconcealable list
        if WEAPON_SCANNER_CONCEALMENT.unconcealableItems then
            for _, unconcealable in ipairs(WEAPON_SCANNER_CONCEALMENT.unconcealableItems) do
                if weaponClass == unconcealable then
                    return false
                end
            end
        end
        
        return true
    end
    
    -- Function to calculate concealment time
    function CWRP_GetConcealmentTime(weaponClass)
        if not WEAPON_SCANNER_CONCEALMENT then
            return 3 -- Default
        end
        
        local baseTime = WEAPON_SCANNER_CONCEALMENT.concealTime or 3
        local multiplier = 1
        
        -- Check if it's a large item (contains certain keywords)
        local largeKeywords = {"rpg", "launcher", "heavy", "rifle"}
        for _, keyword in ipairs(largeKeywords) do
            if string.find(string.lower(weaponClass), keyword) then
                multiplier = multiplier * (WEAPON_SCANNER_CONCEALMENT.largeItemMultiplier or 2)
                break
            end
        end
        
        -- Check if it's a high-danger item
        if ITEM_DANGER_LEVELS and ITEM_DANGER_LEVELS[weaponClass] == "red" then
            multiplier = multiplier * (WEAPON_SCANNER_CONCEALMENT.dangerItemMultiplier or 1.5)
        end
        
        return baseTime * multiplier
    end
    
    -- Network receiver for concealment requests
    net.Receive("CWRP_StartConcealment", function(len, ply)
        if not IsValid(ply) then return end
        
        local weaponClass = net.ReadString()
        
        -- Check if concealment is enabled
        if not WEAPON_SCANNER_CONCEALMENT or not WEAPON_SCANNER_CONCEALMENT.enabled then
            net.Start("CWRP_ConcealmentFailed")
            net.WriteString("Concealment system is disabled.")
            net.Send(ply)
            return
        end
        
        -- Check if player already has maximum concealed items
        local maxSlots = WEAPON_SCANNER_CONCEALMENT.maxConcealedSlots or 2
        if #ply.CWRP_ConcealedItems >= maxSlots then
            net.Start("CWRP_ConcealmentFailed")
            net.WriteString("All concealment slots are full!")
            net.Send(ply)
            return
        end
        
        -- Check if item can be concealed
        if not CWRP_CanConcealItem(weaponClass) then
            net.Start("CWRP_ConcealmentFailed")
            net.WriteString("This item is too large to conceal!")
            net.Send(ply)
            return
        end
        
        -- Check if player has the weapon
        if not ply:HasWeapon(weaponClass) then
            net.Start("CWRP_ConcealmentFailed")
            net.WriteString("You don't have this item!")
            net.Send(ply)
            return
        end
        
        -- Check if already concealed
        for _, concealed in ipairs(ply.CWRP_ConcealedItems) do
            if concealed == weaponClass then
                net.Start("CWRP_ConcealmentFailed")
                net.WriteString("This item is already concealed!")
                net.Send(ply)
                return
            end
        end
        
        -- Start concealment process
        ply.CWRP_ConcealmentInProgress = true
        local concealTime = CWRP_GetConcealmentTime(weaponClass)
        
        net.Start("CWRP_ConcealmentProgress")
        net.WriteString(weaponClass)
        net.WriteFloat(concealTime)
        net.Send(ply)
        
        -- Timer for concealment completion
        timer.Create("CWRP_Conceal_" .. ply:SteamID(), concealTime, 1, function()
            if IsValid(ply) and ply:HasWeapon(weaponClass) then
                table.insert(ply.CWRP_ConcealedItems, weaponClass)
                ply.CWRP_ConcealmentInProgress = false
                
                net.Start("CWRP_ConcealmentComplete")
                net.WriteString(weaponClass)
                net.Send(ply)
                
                ply:ChatPrint("[CONCEALMENT] Successfully concealed: " .. weaponClass)
                
                -- Log concealment
                CWRP_LogAction("CONCEALMENT", 
                    string.format("Player %s concealed item: %s", ply:Nick(), weaponClass))
            end
        end)
    end)
    
    -- Network receiver for revealing items
    net.Receive("CWRP_RevealItem", function(len, ply)
        if not IsValid(ply) then return end
        
        local weaponClass = net.ReadString()
        
        -- Remove from concealed items
        for i, concealed in ipairs(ply.CWRP_ConcealedItems) do
            if concealed == weaponClass then
                table.remove(ply.CWRP_ConcealedItems, i)
                ply:ChatPrint("[CONCEALMENT] Revealed: " .. weaponClass)
                
                -- Log reveal
                CWRP_LogAction("CONCEALMENT", 
                    string.format("Player %s revealed concealed item: %s", ply:Nick(), weaponClass))
                break
            end
        end
    end)
    
    -- Cancel concealment if player moves too much
    hook.Add("PlayerMove", "CWRP_ConcealmentMovementCheck", function(ply, moveData)
        if ply.CWRP_ConcealmentInProgress then
            if not ply.CWRP_ConcealmentStartPos then
                ply.CWRP_ConcealmentStartPos = ply:GetPos()
            else
                local distance = ply:GetPos():Distance(ply.CWRP_ConcealmentStartPos)
                if distance > 50 then -- Moved more than 50 units
                    timer.Remove("CWRP_Conceal_" .. ply:SteamID())
                    ply.CWRP_ConcealmentInProgress = false
                    ply.CWRP_ConcealmentStartPos = nil
                    
                    net.Start("CWRP_ConcealmentFailed")
                    net.WriteString("Concealment cancelled - you moved too much!")
                    net.Send(ply)
                end
            end
        else
            ply.CWRP_ConcealmentStartPos = nil
        end
    end)
end

if CLIENT then
    -- Client-side concealment UI
    local concealmentActive = false
    local concealmentProgress = 0
    local concealmentItem = ""
    local concealmentTime = 0
    local concealmentStartTime = 0
    
    -- Network receivers
    net.Receive("CWRP_ConcealmentProgress", function()
        concealmentItem = net.ReadString()
        concealmentTime = net.ReadFloat()
        concealmentStartTime = CurTime()
        concealmentActive = true
        concealmentProgress = 0
    end)
    
    net.Receive("CWRP_ConcealmentComplete", function()
        local item = net.ReadString()
        concealmentActive = false
        chat.AddText(Color(0, 255, 0), "[CONCEALMENT] Successfully concealed: " .. item)
    end)
    
    net.Receive("CWRP_ConcealmentFailed", function()
        local message = net.ReadString()
        concealmentActive = false
        chat.AddText(Color(255, 100, 100), "[CONCEALMENT] " .. message)
    end)
    
    -- Draw concealment progress bar
    hook.Add("HUDPaint", "CWRP_DrawConcealmentProgress", function()
        if not concealmentActive then return end
        
        local elapsed = CurTime() - concealmentStartTime
        concealmentProgress = math.Clamp(elapsed / concealmentTime, 0, 1)
        
        local scrW, scrH = ScrW(), ScrH()
        local barW, barH = 400, 40
        local barX, barY = scrW / 2 - barW / 2, scrH * 0.7
        
        -- Background
        draw.RoundedBox(4, barX - 4, barY - 4, barW + 8, barH + 8, Color(0, 0, 0, 200))
        
        -- Progress bar
        local progressW = barW * concealmentProgress
        draw.RoundedBox(4, barX, barY, progressW, barH, Color(100, 200, 255, 200))
        
        -- Border
        draw.RoundedBox(4, barX, barY, barW, barH, Color(255, 255, 255, 50))
        
        -- Text
        draw.SimpleText("Concealing: " .. concealmentItem, "DermaLarge", scrW / 2, barY - 20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(string.format("%.1fs / %.1fs", elapsed, concealmentTime), "DermaDefault", scrW / 2, barY + barH / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Hold position to conceal...", "DermaDefault", scrW / 2, barY + barH + 15, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end)
    
    -- Command to start concealment (can be bound to a key)
    concommand.Add("cwrp_conceal_weapon", function(ply, cmd, args)
        if #args < 1 then
            chat.AddText(Color(255, 100, 100), "[CONCEALMENT] Usage: cwrp_conceal_weapon <weapon_class>")
            return
        end
        
        local weaponClass = args[1]
        
        net.Start("CWRP_StartConcealment")
        net.WriteString(weaponClass)
        net.SendToServer()
    end)
    
    -- Command to reveal concealed item
    concommand.Add("cwrp_reveal_weapon", function(ply, cmd, args)
        if #args < 1 then
            chat.AddText(Color(255, 100, 100), "[CONCEALMENT] Usage: cwrp_reveal_weapon <weapon_class>")
            return
        end
        
        local weaponClass = args[1]
        
        net.Start("CWRP_RevealItem")
        net.WriteString(weaponClass)
        net.SendToServer()
    end)
end
