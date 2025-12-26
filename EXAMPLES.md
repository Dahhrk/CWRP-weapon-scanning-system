# CWRP Weapon Scanning System - Usage Examples

This document provides practical examples of all features in the CWRP Weapon Scanning System, including the latest updates.

---

## Feature 1: Job-Based Scan Bypass (NEW)

### Configuration
```lua
-- In weapon_scanner_config.lua

-- Jobs that cannot be scanned
WEAPON_SCANNER_JOB_BYPASS = {
    [TEAM_SITHSPY] = true,
    [TEAM_SPECIALAGENT] = true,
    [TEAM_UNDERCOVER] = true
}
```

### Example Scenario
1. **Guard** attempts to scan a **Sith Spy** (TEAM_SITHSPY)
2. **Scanner Output** to Guard:
   ```
   This role cannot be scanned.
   ```
3. **Admin Log**:
   ```
   [JOB BYPASS] Player SithSpy123 (Team: Sith Spy) bypassed scan by Guard456 due to job-based bypass
   ```
4. No weapons are revealed, maintaining the spy's cover

### Migration from Bypass Scanning SWEP
**Before (DEPRECATED)**:
```lua
-- Players needed to equip bypass scanning swep
SWEP_ALLOWED_TEAMS["weapon_bypass_scanning_swep"] = {TEAM_SITHSPY}
```

**After (RECOMMENDED)**:
```lua
-- Job-based bypass is automatic and consistent
WEAPON_SCANNER_JOB_BYPASS = {
    [TEAM_SITHSPY] = true
}
```

---

## Feature 2: Danger Level Highlighting (NEW)

### Configuration
```lua
-- In weapon_scanner_config.lua

ITEM_DANGER_LEVELS = {
    -- Green - Low threat
    ["weapon_physgun"] = "green",
    ["gmod_tool"] = "green",
    ["med_kit"] = "green",
    ["armor_kit"] = "green",
    
    -- Yellow - Questionable/Restricted
    ["weapon_pistol"] = "yellow",
    ["weapon_smg1"] = "yellow",
    ["lockpick"] = "yellow",
    
    -- Red - High-danger contraband
    ["weapon_rpg"] = "red",
    ["weapon_frag"] = "red",
    ["ls_lightsaber"] = "red",
    ["weapon_c4"] = "red"
}
```

### Example Scenario
1. **Guard** scans a **Trooper**
2. **Trooper** has: `med_kit`, `weapon_pistol`, `weapon_rpg`, `ls_lightsaber`
3. **Scanner Output** to Guard:
   ```
   [SCANNING...]
   === Scan Results for Trooper ===
   ⚠ CRITICAL CONTRABAND DETECTED ⚠
   HIGH-DANGER ITEMS:
     [⚠] weapon_rpg
     [⚠] ls_lightsaber
   QUESTIONABLE ITEMS:
     [!] weapon_pistol
   LOW-THREAT ITEMS:
     [✓] med_kit
   [SCAN COMPLETE]
   ```
4. **Nearby Guards** receive specific alerts:
   ```
   [ALERT] High-danger item detected: weapon_rpg in Trooper's inventory!
   [ALERT] High-danger item detected: ls_lightsaber in Trooper's inventory!
   ```

---

## Feature 3: Item-Job Exceptions (NEW)

### Configuration
```lua
-- In weapon_scanner_config.lua

ITEM_JOB_EXCEPTIONS = {
    ["weapon_lightsaber"] = {
        [TEAM_JEDI] = "allowed",      -- Jedi can have lightsabers
        [TEAM_SITH] = "allowed",       -- Sith can have lightsabers
        [TEAM_PADAWAN] = "yellow",     -- Padawans are questionable
        [TEAM_CIVILIAN] = "red"        -- Civilians definitely cannot
    },
    ["ls_lightsaber"] = {
        [TEAM_JEDI] = "allowed",
        [TEAM_SITH] = "allowed",
        [TEAM_CIVILIAN] = "red"
    },
    ["weapon_rpg"] = {
        [TEAM_HEAVY] = "yellow",       -- Heavy class can have RPG (questionable but allowed)
        [TEAM_ARCTROOP] = "yellow",    -- ARC troopers can have RPG
        [TEAM_CIVILIAN] = "red"        -- Civilians cannot
    }
}
```

### Example Scenario 1: Authorized Lightsaber
1. **Guard** scans a **Jedi Knight** (TEAM_JEDI)
2. **Jedi** has: `weapon_lightsaber`, `med_kit`
3. **Scanner Output**:
   ```
   [SCANNING...]
   === Scan Results for Jedi Knight ===
   ALLOWED ITEMS:
     [✓] weapon_lightsaber
   LOW-THREAT ITEMS:
     [✓] med_kit
   [SCAN COMPLETE]
   ```
4. Lightsaber shows as allowed due to job exception

### Example Scenario 2: Unauthorized Lightsaber
1. **Guard** scans a **Civilian** (TEAM_CIVILIAN)
2. **Civilian** has: `weapon_lightsaber`, `med_kit`
3. **Scanner Output**:
   ```
   [SCANNING...]
   === Scan Results for Civilian ===
   ⚠ CRITICAL CONTRABAND DETECTED ⚠
   HIGH-DANGER ITEMS:
     [⚠] weapon_lightsaber
   LOW-THREAT ITEMS:
     [✓] med_kit
   [SCAN COMPLETE]
   ```
4. **Nearby Guards** receive alert:
   ```
   [ALERT] High-danger item detected: weapon_lightsaber in Civilian's inventory!
   ```

---

## Feature 4: Concealment Mechanic (NEW)

### Configuration
```lua
-- In weapon_scanner_config.lua

WEAPON_SCANNER_CONCEALMENT = {
    enabled = true,
    maxConcealedSlots = 2,              -- Max 2 items can be concealed
    concealTime = 3,                     -- Base 3 seconds to conceal
    largeItemMultiplier = 2,             -- 2x time for large items
    dangerItemMultiplier = 1.5,          -- 1.5x time for dangerous items
    concealKey = KEY_E,                  
    unconcealableItems = {
        "weapon_rpg",                    -- Too large to conceal
        "weapon_slam",
        "weapon_c4",
        "tfa_detonator"
    }
}
```

### Example Scenario 1: Successful Concealment
1. **Suspect** knows they're about to be scanned
2. **Suspect** has: `weapon_pistol`, `lockpick`, `med_kit`
3. **Suspect** runs console command:
   ```
   cwrp_conceal_weapon weapon_pistol
   ```
4. **Progress bar** appears showing concealment progress
5. After 3 seconds (if Suspect doesn't move):
   ```
   [CONCEALMENT] Successfully concealed: weapon_pistol
   ```
6. **Guard** scans the **Suspect**
7. **Scanner Output** (pistol is hidden):
   ```
   [SCANNING...]
   === Scan Results for Suspect ===
   QUESTIONABLE ITEMS:
     [!] lockpick
   LOW-THREAT ITEMS:
     [✓] med_kit
   [SCAN COMPLETE]
   ```

### Example Scenario 2: Failed Concealment (Movement)
1. **Suspect** tries to conceal `weapon_pistol`
2. **Suspect** moves more than 50 units during concealment
3. **Concealment cancelled**:
   ```
   [CONCEALMENT] Concealment cancelled - you moved too much!
   ```
4. Item remains visible during scans

### Example Scenario 3: Large Item Concealment
1. **Suspect** tries to conceal `weapon_frag` (marked as dangerous)
2. Concealment time: 3 seconds × 1.5 (danger multiplier) = 4.5 seconds
3. **Progress bar** shows longer concealment time
4. After 4.5 seconds:
   ```
   [CONCEALMENT] Successfully concealed: weapon_frag
   ```

### Example Scenario 4: Unconcealable Item
1. **Suspect** tries to conceal `weapon_rpg`
2. **System response**:
   ```
   [CONCEALMENT] This item is too large to conceal!
   ```

### Revealing Concealed Items
```
cwrp_reveal_weapon weapon_pistol
```
Output:
```
[CONCEALMENT] Revealed: weapon_pistol
```

---

## Feature 5: Systematic Slot-by-Slot Scanning (NEW)

### Configuration
```lua
-- In weapon_scanner_config.lua

WEAPON_SCANNER_SYSTEMATIC = {
    enabled = true,
    slotDelay = 1,                       -- 1 second between slots
    showProgress = true,                 -- Show progress to guard
    cancelOnMove = false,                -- Don't cancel if target moves
    maxScanDistance = 200                -- Max 200 units distance
}
```

### Example Scenario
1. **Guard** scans a **Suspect** with 5 weapons
2. **Guard** sees progressive scan:
   ```
   [SYSTEMATIC SCAN] Starting slot-by-slot scan...
   [SCANNING] Slot 1/5...
   (1 second delay)
   [SCANNING] Slot 2/5...
   (1 second delay)
   [SCANNING] Slot 3/5...
   (1 second delay)
   [SCANNING] Slot 4/5...
   (1 second delay)
   [SCANNING] Slot 5/5...
   ```
3. After all slots scanned, full results displayed:
   ```
   [SCANNING...]
   === Scan Results for Suspect ===
   HIGH-DANGER ITEMS:
     [⚠] weapon_rpg
   QUESTIONABLE ITEMS:
     [!] weapon_pistol
     [!] weapon_smg1
   LOW-THREAT ITEMS:
     [✓] med_kit
     [✓] gmod_tool
   [SCAN COMPLETE]
   ```

### Distance Cancellation
1. **Guard** starts systematic scan
2. **Suspect** runs away (more than 200 units)
3. **Guard** sees:
   ```
   [SCAN CANCELLED] Target moved out of range.
   ```

---

## Feature 6: Enhanced Guard Alerts (NEW)

### Configuration
```lua
WEAPON_SCANNER_CONTRABAND_ALERTS = {
    enabled = true,
    alertRadius = 500,
    soundEffect = "buttons/button17.wav",
    playSound = true,
    alertTeams = {
        TEAM_SHOCK,
        TEAM_TEMPLEGUARD,
        TEAM_5THFLEET,
        TEAM_COMMANDER
    }
}

WEAPON_SCANNER_MESSAGES = {
    dangerAlert = "[ALERT] High-danger item detected: %s in %s's inventory!",
    restrictedAlert = "[ALERT] Restricted item detected: %s on %s"
}
```

### Example Scenario
1. **Guard1** scans **Criminal** who has `weapon_rpg` and `weapon_c4`
2. **Guard1** sees scan results with contraband
3. **Guard2** and **Guard3** (within 500 units, on alert teams) receive:
   ```
   [ALERT] High-danger item detected: weapon_rpg in Criminal's inventory!
   [ALERT] High-danger item detected: weapon_c4 in Criminal's inventory!
   ```
4. Sound effect plays for all alerted guards
5. Guards can respond immediately to the threat

---

## Feature 7: Comprehensive Admin Logging (NEW)

### Console Log Output
```
[WEAPON SCAN] Guard ShockTrooper123 scanned Suspect456 (Team: Civilian) - Red: 2, Yellow: 1, Green: 2, Allowed: 0 | scanner: ShockTrooper123 | scannerSteamID: STEAM_0:1:12345 | target: Suspect456 | targetSteamID: STEAM_0:1:67890 | targetTeam: Civilian | redItems: weapon_rpg, weapon_c4 | yellowItems: weapon_pistol | greenItems: med_kit, armor_kit | totalItems: 5
```

### Billy's Logs Integration
If Billy's Logs addon is installed, all scans appear in the admin logs with full details:
- Scanner name and SteamID
- Target name and SteamID
- Target team
- All detected items categorized by danger level
- Timestamp

### Confiscation Logging
```
[CONFISCATION] Guard ShockTrooper123 confiscated 3 items from Suspect456 | confiscator: ShockTrooper123 | confiscatorSteamID: STEAM_0:1:12345 | target: Suspect456 | targetSteamID: STEAM_0:1:67890 | confiscatedItems: weapon_rpg, weapon_c4, weapon_pistol | itemCount: 3
```

### Job Bypass Logging
```
[JOB BYPASS] Player SithSpy123 (Team: Sith Spy) bypassed scan by Guard456 due to job-based bypass
```

### Concealment Logging
```
[CONCEALMENT] Player Suspect789 concealed item: weapon_pistol
[CONCEALMENT] Player Suspect789 revealed concealed item: weapon_pistol
```

---

## Combined Feature Examples

### Scenario 1: High-Security Checkpoint
**Setup**:
- Multiple guards from TEAM_SHOCK
- Systematic scanning enabled (1 second per slot)
- Contraband alerts enabled (500-unit radius)
- Concealment system active

**Case A: Clean Civilian**
1. Guard scans civilian with only `med_kit` and `gmod_tool`
2. Output:
   ```
   [SYSTEMATIC SCAN] Starting slot-by-slot scan...
   [SCANNING] Slot 1/2...
   [SCANNING] Slot 2/2...
   [SCANNING...]
   === Scan Results for Civilian ===
   LOW-THREAT ITEMS:
     [✓] med_kit
     [✓] gmod_tool
   [SCAN COMPLETE]
   ```
3. Civilian proceeds through checkpoint

**Case B: Jedi with Lightsaber**
1. Guard scans Jedi Knight with `weapon_lightsaber` and `med_kit`
2. Output:
   ```
   [SCANNING...]
   === Scan Results for Jedi Knight ===
   ALLOWED ITEMS:
     [✓] weapon_lightsaber
   LOW-THREAT ITEMS:
     [✓] med_kit
   [SCAN COMPLETE]
   ```
3. Lightsaber allowed due to job exception
4. No alerts triggered

**Case C: Smuggler with Concealed Contraband**
1. Smuggler has `weapon_c4`, `weapon_pistol`, `lockpick`
2. Smuggler conceals `weapon_pistol` before checkpoint
3. Guard scans smuggler
4. Output:
   ```
   [SCANNING...]
   === Scan Results for Smuggler ===
   ⚠ CRITICAL CONTRABAND DETECTED ⚠
   HIGH-DANGER ITEMS:
     [⚠] weapon_c4
   QUESTIONABLE ITEMS:
     [!] lockpick
   [SCAN COMPLETE]
   ```
5. Nearby guards alerted about C4
6. Concealed pistol remains hidden
7. Admin log records scan with detected items

**Case D: Sith Spy (Job Bypass)**
1. Guard attempts to scan Sith Spy
2. Output:
   ```
   This role cannot be scanned.
   ```
3. No items revealed
4. Admin log records bypass attempt

### Scenario 2: Confiscation and Recovery
1. Guard confiscates all weapons from Criminal
2. Admin log:
   ```
   [CONFISCATION] Guard confiscated 5 items from Criminal
   ```
3. If guard dies, weapons automatically returned:
   ```
   Your confiscated weapons have been returned because the confiscator died!
   ```

### Scenario 3: Custom Server Configuration
**Theme: Maximum Security Prison**
```lua
-- Strict scanning with no bypass
WEAPON_SCANNER_JOB_BYPASS = {}

-- Everything is high danger in prison
ITEM_DANGER_LEVELS = {
    ["weapon_pistol"] = "red",
    ["lockpick"] = "red",
    ["keypad_cracker"] = "red",
    ["weapon_knife"] = "red"
}

-- No exceptions
ITEM_JOB_EXCEPTIONS = {}

-- Disable concealment
WEAPON_SCANNER_CONCEALMENT = {
    enabled = false
}

-- Fast systematic scanning
WEAPON_SCANNER_SYSTEMATIC = {
    enabled = true,
    slotDelay = 0.5,  -- Quick scans
    showProgress = true
}
```

---

## Troubleshooting

### Job Bypass Not Working
- Verify `WEAPON_SCANNER_JOB_BYPASS` contains correct team ID
- Check team ID matches the target's actual team
- Ensure config file loads before SWEPs

### Danger Levels Not Showing
- Confirm `ITEM_DANGER_LEVELS` table is properly configured
- Check weapon class names are exact matches
- Verify no Lua syntax errors in config

### Concealment Not Working
- Ensure `WEAPON_SCANNER_CONCEALMENT.enabled = true`
- Check player hasn't exceeded `maxConcealedSlots`
- Verify item isn't in `unconcealableItems` list
- Confirm player isn't moving during concealment

### Systematic Scanning Too Slow/Fast
- Adjust `WEAPON_SCANNER_SYSTEMATIC.slotDelay` value
- Set to 0 for instant scanning
- Increase for more dramatic effect

### Alerts Not Triggering
- Verify `WEAPON_SCANNER_CONTRABAND_ALERTS.enabled = true`
- Check item is marked as "red" danger level
- Confirm alert teams are properly defined
- Verify guards are within alert radius

### Logs Not Appearing
- Enable console logging: `ENABLE_SERVER_CONSOLE_LOGGING = true`
- Check Billy's Logs addon is installed and working
- Verify no errors in server console

---

## Best Practices

1. **Job Bypass Configuration**: Only give bypass to roles that truly need it (spies, undercover agents)
2. **Danger Level Assignment**: Be consistent - weapons of similar power should have similar danger levels
3. **Item-Job Exceptions**: Use sparingly - most restrictions should be handled by danger levels
4. **Concealment Settings**: Balance realism with gameplay - too easy makes scanning pointless, too hard frustrates players
5. **Systematic Scanning**: 1-second delay is good for RP, 0 seconds for busy servers
6. **Alert Radius**: 500 units works for medium maps, adjust for your map size
7. **Sound Effects**: Use appropriate sounds that fit your server theme
8. **Logging**: Always keep enabled for admin transparency and issue investigation

---

## Advanced Usage

### Creating Custom Danger Profiles

**Military Base**:
```lua
-- Military weapons are yellow, not red
ITEM_DANGER_LEVELS = {
    ["weapon_rifle"] = "yellow",
    ["weapon_pistol"] = "yellow",
    ["weapon_rpg"] = "red"  -- Still illegal
}
```

**Civilian Area**:
```lua
-- All weapons are red in civilian zones
ITEM_DANGER_LEVELS = {
    ["weapon_pistol"] = "red",
    ["weapon_knife"] = "red",
    ["weapon_rifle"] = "red"
}
```

### Hook Integration

```lua
-- Custom hook when high-danger item detected
hook.Add("CWRP_PlayerScanned", "CustomRedAlert", function(scanner, target, scanData)
    if scanData.redItems and #scanData.redItems > 0 then
        -- Custom logic
        PrintMessage(HUD_PRINTTALK, "LOCKDOWN INITIATED!")
        -- Trigger alarm, lock doors, etc.
    end
end)
```

---

Thank you for using the CWRP Weapon Scanning System!
