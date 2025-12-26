# CWRP Weapon Scanning System

The CWRP Weapon Scanning System is a powerful tool designed to enhance roleplay (RP) realism by enabling detailed weapon scanning and confiscation capabilities with advanced features for security, concealment, and job-based restrictions. It allows for streamlined security processes within the Clone Wars RP (CWRP) community.

## New Features (Latest Update)

### 1. Job-Based Scan Bypass
The system now supports job-based bypass functionality, replacing the deprecated Cloaking Device SWEP:
- **Job Bypass Configuration**: Configure jobs that cannot be scanned using `WEAPON_SCANNER_JOB_BYPASS`
- **Seamless Integration**: Guards are notified when attempting to scan bypass-enabled roles
- **Admin Logging**: All bypass attempts are logged for transparency

Configure job bypass in `weapon_scanner_config.lua`:
```lua
WEAPON_SCANNER_JOB_BYPASS = {
    [TEAM_SITHSPY] = true,
    [TEAM_SPECIALAGENT] = true
}
```

**Note**: The Cloaking Device SWEP is now deprecated. Use job-based bypass instead for better server management and consistency.

### 2. Danger Level Highlighting
Items are now color-coded by threat level during scans:
- **🟢 Green**: Low threat (consumables, common tools like medkits)
- **🟡 Yellow**: Questionable/Restricted (unauthorized tools, small drugs, basic weapons)
- **🔴 Red**: High-danger contraband (lightsabers, explosives, heavy weapons)

Configure danger levels in `weapon_scanner_config.lua`:
```lua
ITEM_DANGER_LEVELS = {
    ["med_kit"] = "green",
    ["weapon_pistol"] = "yellow",
    ["weapon_rpg"] = "red",
    ["ls_lightsaber"] = "red"
}
```

### 3. Item-Job Exceptions
Define which items are allowed or restricted for specific jobs:
- **Flexible Rules**: Different jobs can have different permissions for the same item
- **Job-Specific Permissions**: Lightsabers allowed for Jedi but flagged red for civilians
- **Easy Configuration**: Centralized exception table for all items

Configure exceptions in `weapon_scanner_config.lua`:
```lua
ITEM_JOB_EXCEPTIONS = {
    ["weapon_lightsaber"] = {
        [TEAM_JEDI] = "allowed",
        [TEAM_SITH] = "allowed",
        [TEAM_CIVILIAN] = "red"
    }
}
```

### 4. Concealment Mechanic
Players can now hide items during scans:
- **Interactive System**: Hold position to conceal items into special slots
- **Progress Bar**: Visual feedback during concealment process
- **Size Restrictions**: Large or high-danger items take longer to conceal
- **Limited Slots**: Configurable maximum concealed items (default: 2)
- **Unconcealable Items**: Certain items (like explosives) cannot be concealed

Commands:
- `cwrp_conceal_weapon <weapon_class>` - Start concealing a weapon
- `cwrp_reveal_weapon <weapon_class>` - Reveal a concealed weapon

### 5. Systematic Slot-by-Slot Scanning
Enhanced scanning mechanics for tension and realism:
- **Progressive Scanning**: Items are revealed one slot at a time
- **Configurable Delay**: Adjust scan speed for dramatic effect
- **Distance Checking**: Scans cancel if target moves too far away
- **Progress Feedback**: Guards see real-time scan progress

Configure in `weapon_scanner_config.lua`:
```lua
WEAPON_SCANNER_SYSTEMATIC = {
    enabled = true,
    slotDelay = 1,  -- 1 second per slot
    showProgress = true,
    maxScanDistance = 200
}
```

### 6. Enhanced Guard Alerts
Real-time notifications for security personnel:
- **Item-Specific Alerts**: Guards notified of each high-danger item found
- **Detailed Messages**: Alert format: `[ALERT] High-danger item detected: weapon_rpg in Player123's inventory!`
- **Radius-Based**: Only nearby guards receive alerts
- **Team Filtering**: Configure which teams receive alerts

### 7. Comprehensive Admin Logging
All security actions are logged for server transparency:
- **Scan Logs**: Complete record of who scanned whom and what was found
- **Item Details**: Logs include all detected items by danger level
- **Confiscation Logs**: Track all confiscated items with timestamps
- **Bypass Logs**: Record all scan bypass events and reasons
- **Billy's Logs Integration**: Automatic integration with popular logging addon

Example log output:
```
[SCAN] Guard Player1 scanned Suspect234 (Team: Civilian) - Red: 2, Yellow: 1, Green: 3, Allowed: 0
  High-Danger Items: weapon_rpg, ls_lightsaber
  Questionable Items: weapon_pistol
  Low-Threat Items: med_kit, armor_kit, gmod_camera
```

## Legacy Features

### 1. Contraband Detection and Alerts (Now Enhanced with Danger Levels)
The system includes advanced contraband detection capabilities:
- **Critical Contraband List**: Specific items can be marked as high-priority contraband
- **Automatic Alerts**: When contraband is detected, the scanner automatically notifies nearby guards
- **Sound Effects**: Optional audio alerts for contraband detection
- **Visual Indicators**: Contraband items are marked with special indicators

Configure contraband in `weapon_scanner_config.lua`:
```lua
WEAPON_SCANNER_CONTRABAND = {
    "weapon_rpg",
    "weapon_frag",
    "ls_lightsaber"
}
```

### 2. Stealth and Anti-Detection Mechanics (DEPRECATED)
**Note**: Stealth roles and the Cloaking Device SWEP are deprecated. Use `WEAPON_SCANNER_JOB_BYPASS` instead.

The legacy system supports:
- **Stealth Roles**: Certain roles can bypass scanner detection (deprecated, use job bypass)
- **Stealth Teams**: Entire teams can be configured for scanner immunity (deprecated, use job bypass)
- **Cloaking Device SWEP**: Special weapon that spoofs scans (deprecated, use job bypass)

### 3. Customized Scan Messages
Scan results are immersive and informative:
- **Clear Categories**: Weapons organized by danger level
- **Custom Messages**: All scan messages can be personalized
- **Sound Effects**: Optional scan sounds for enhanced immersion
- **Danger Level Indicators**: Special markers for each threat level

Example scan output:
```
[SCANNING...]
=== Scan Results for [PlayerName] ===
⚠ CRITICAL CONTRABAND DETECTED ⚠
HIGH-DANGER ITEMS:
  [⚠] weapon_rpg
  [⚠] ls_lightsaber
QUESTIONABLE ITEMS:
  [!] weapon_pistol
LOW-THREAT ITEMS:
  [✓] med_kit
  [✓] armor_kit
[SCAN COMPLETE]
```

## Usage Instructions

### Overview
Guards who use the weapon scanners and confiscators must be trained and authorized. Typically, these roles include:
- **Shock Troopers**
- **Temple Guards**
- **5th Fleet Security**
- **Regimental Commanders or above**

These positions are crucial for maintaining RP authenticity and ensuring that security protocols are enforced accurately and fairly. Only players assigned to one of these roles should handle these tools.

### Key Features
1. **Weapon Scanning**:
   - Scans weapons being carried by individuals with danger level highlighting
   - Detects contraband items and alerts nearby guards
   - Categorizes weapons by threat level (red, yellow, green)
   - Respects job-based bypass configuration
   - Progressive slot-by-slot scanning for tension

2. **Weapon Confiscation**:
   - Confiscate prohibited items securely and log the details for review
   - All confiscations are logged with full details

3. **Concealment System**:
   - Players can hide items from scans
   - Limited concealment slots
   - Time-based concealment with progress bar
   - Size and danger restrictions

4. **Authentication Integration**:
   - Validate the authority level of the scanning personnel
   - Job-based bypass for special roles

5. **Item-Job Exceptions**:
   - Define which items are allowed per job
   - Flexible permission system

6. **Comprehensive Logging**:
   - All scans, confiscations, and bypasses logged
   - Integration with Billy's Logs
   - Console logging for debugging

### Roleplay Guidelines
- Always treat scanned individuals with respect and adhere to community rules.
- Ensure that scanning and confiscation actions are logged for transparency and accountability purposes.
- Use the scanner and confiscator tools sparingly to avoid disrupting RP flow unnecessarily.
- Be aware that players can conceal items - investigate suspicious behavior.

### Important Notes
The use of the Weapon Scanning System is not only a matter of enforcement but also a significant contributor to creating an immersive and authentic RP experience. Guards play an essential part in setting the tone of the RP environment and reinforcing the rules of the community.

## Configuration Guide

### Basic Setup
All configuration is done in `lua/config/weapon_scanner_config.lua`:

1. **Job Bypass**: Define which jobs cannot be scanned
2. **Danger Levels**: Set threat levels for all items
3. **Item-Job Exceptions**: Configure job-specific item permissions
4. **Concealment**: Enable/disable and configure concealment mechanics
5. **Systematic Scanning**: Configure progressive scanning behavior
6. **Alert Settings**: Set up guard alert radius and teams

### Advanced Configuration
- Customize all scan messages
- Configure sound effects
- Set team permissions for SWEPs
- Configure Billy's Logs integration

## Migration from Cloaking Device

If you were using the Cloaking Device SWEP:

1. **Remove** cloaking devices from jobs
2. **Add** jobs to `WEAPON_SCANNER_JOB_BYPASS` instead:
   ```lua
   WEAPON_SCANNER_JOB_BYPASS = {
       [TEAM_SITHSPY] = true,
       [TEAM_BOUNTYHUNTER] = true
   }
   ```
3. The cloaking device will show a deprecation warning if used

## Development
If you encounter an issue or have suggestions for improvements, feel free to open an issue or submit a pull request. Your contributions help make this system even better for everyone!

---

Thank you for using the CWRP Weapon Scanning System. Together, we can build a secure and engaging roleplay experience.