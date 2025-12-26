# CWRP Weapon Scanning System - Usage Examples

This document provides practical examples of the new features in the CWRP Weapon Scanning System.

## Feature 1: Contraband Detection and Alerts

### Configuration
```lua
-- In weapon_scanner_config.lua

-- Define critical contraband items
WEAPON_SCANNER_CONTRABAND = {
    "weapon_rpg",
    "weapon_frag",
    "weapon_slam",
    "ls_lightsaber",
    "weapon_c4"
}

-- Configure alert settings
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
```

### Example Scenario
1. **Guard** uses weapon scanner on a **Suspect**
2. **Suspect** has: `weapon_physgun`, `weapon_rpg`, `ls_lightsaber`
3. **Scanner Output** to Guard:
   ```
   [SCANNING...]
   === Scan Results for Suspect ===
   ⚠ CRITICAL CONTRABAND DETECTED ⚠
   BLACKLISTED ITEMS:
     [⚠] weapon_rpg
     [⚠] ls_lightsaber
   ALLOWED ITEMS:
     [✓] weapon_physgun
   [SCAN COMPLETE]
   ```
4. **Nearby Guards** (within 500 units) receive:
   ```
   ⚠ [ALERT] Contraband detected on Suspect by Guard
   ```
5. Sound effects play for both the scanner and nearby guards

## Feature 2: Stealth and Anti-Detection Mechanics

### Configuration for Stealth Roles
```lua
-- In weapon_scanner_config.lua

-- Role-based stealth
WEAPON_SCANNER_STEALTH_ROLES = {
    ["SithAssassin"] = true,
    ["Spy"] = true
}

-- Team-based stealth
WEAPON_SCANNER_STEALTH_TEAMS = {
    [TEAM_SITHSPY] = true,
    [TEAM_BOUNTYHUNTER] = true
}
```

### Example Scenario 1: Stealth Role
1. **Guard** scans a player with usergroup "SithAssassin"
2. **Scanner Output**:
   ```
   Scan bypassed - Stealth technology detected.
   ```
3. No weapons are revealed

### Example Scenario 2: Cloaking Device
1. **Spy** equips `weapon_cloaking_device` SWEP
2. **Spy receives message**:
   ```
   [Cloaking Device] Deployed - Your weapons are now hidden from scanners.
   [Cloaking Device] While equipped, scans will show 'Empty pockets'.
   ```
3. **Guard** scans the **Spy**
4. **Scanner Output**:
   ```
   Scan complete - Empty pockets detected.
   ```
5. Spy's actual weapons remain hidden

### Configuring Cloaking Device Access
```lua
-- In weapon_scanner_config.lua
SWEP_ALLOWED_TEAMS = {
    ["weapon_cloaking_device"] = {
        TEAM_SITHSPY,
        TEAM_BOUNTYHUNTER,
        TEAM_SPECIALAGENT
    }
}
```

## Feature 3: Customized Scan Messages

### Configuration
```lua
-- In weapon_scanner_config.lua
WEAPON_SCANNER_MESSAGES = {
    scanStart = "[SECURITY SCAN INITIATED]",
    scanComplete = "[SCAN TERMINATED]",
    noWeapons = "Subject is unarmed.",
    allowedHeader = "PERMITTED EQUIPMENT:",
    blacklistedHeader = "UNAUTHORIZED EQUIPMENT:",
    contrabandDetected = "⚠⚠⚠ THREAT LEVEL: CRITICAL ⚠⚠⚠",
    stealthBypass = "ERROR: Unable to penetrate cloaking field.",
    scanSound = "buttons/button14.wav",
    playScanSound = true
}
```

### Example Output with Custom Messages
```
[SECURITY SCAN INITIATED]
=== Scan Results for Trooper ===
⚠⚠⚠ THREAT LEVEL: CRITICAL ⚠⚠⚠
UNAUTHORIZED EQUIPMENT:
  [⚠] weapon_slam
  [!] weapon_frag
PERMITTED EQUIPMENT:
  [✓] weapon_physgun
  [✓] gmod_tool
[SCAN TERMINATED]
```

## Combined Feature Example

### Scenario: High-Security Checkpoint
1. **Setup**:
   - Checkpoint has multiple guards from TEAM_SHOCK
   - Contraband alerts enabled with 500-unit radius
   - Some VIPs have role bypass
   - Spies have cloaking devices

2. **Case A: Regular Trooper with Contraband**:
   - Guard scans trooper with `weapon_c4`
   - All nearby guards are alerted
   - Sound effects play
   - Trooper's weapons displayed with contraband marker [⚠]

3. **Case B: VIP Player**:
   - Guard scans VIP (usergroup "VIP")
   - Output: `Player VIPName has scanning immunity.`
   - No weapons revealed

4. **Case C: Spy with Cloaking Device**:
   - Guard scans spy who has cloaking device equipped
   - Output: `Scan complete - Empty pockets detected.`
   - Spy's actual weapons (including contraband) remain hidden

5. **Case D: Sith Assassin Role**:
   - Guard scans player with "SithAssassin" usergroup
   - Output: `Scan bypassed - Stealth technology detected.`
   - No scan results shown

## Integration with Existing Features

All new features integrate seamlessly with:
- **Billy's Logs**: Cloaking device usage is logged
- **Team Permissions**: All SWEPs respect team restrictions
- **Confiscation System**: Works normally when contraband is detected
- **CWRP_PlayerScanned Hook**: Now includes `contrabandItems` in scan data

### Hook Usage Example
```lua
hook.Add("CWRP_PlayerScanned", "CustomContrabandHandler", function(scanner, target, scanData)
    if #scanData.contrabandItems > 0 then
        -- Custom logic when contraband is detected
        print("Contraband found on " .. target:Nick())
        -- Send to administration system, etc.
    end
end)
```

## Troubleshooting

### Contraband Alerts Not Working
- Ensure `WEAPON_SCANNER_CONTRABAND_ALERTS.enabled = true`
- Check that `WEAPON_SCANNER_CONTRABAND` contains the weapon classes
- Verify alert teams are properly defined

### Stealth Not Working
- Check player's usergroup matches `WEAPON_SCANNER_STEALTH_ROLES`
- Verify team ID in `WEAPON_SCANNER_STEALTH_TEAMS`
- For cloaking device, ensure it's equipped (not just in inventory)

### Custom Messages Not Showing
- Verify `WEAPON_SCANNER_MESSAGES` table is properly configured
- Check for Lua syntax errors in config file
- Ensure config file is loaded before SWEPs

## Best Practices

1. **Contraband Configuration**: Only mark truly critical items as contraband to avoid alert spam
2. **Stealth Access**: Limit stealth roles to specific, trusted roles to maintain balance
3. **Alert Radius**: Adjust based on your map size (500 is good for medium maps)
4. **Sound Effects**: Use appropriate sounds that fit your server's theme
5. **Message Customization**: Keep messages clear and concise for better RP experience
