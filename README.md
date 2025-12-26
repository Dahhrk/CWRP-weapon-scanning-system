# CWRP Weapon Scanning System

The CWRP Weapon Scanning System is a powerful tool designed to enhance roleplay (RP) realism by enabling detailed weapon scanning and confiscation capabilities. It allows for streamlined security processes within the Clone Wars RP (CWRP) community.

## New Features

### 1. Contraband Detection and Alerts
The system now includes advanced contraband detection capabilities:
- **Critical Contraband List**: Specific items can be marked as high-priority contraband (e.g., explosives, lightsabers)
- **Automatic Alerts**: When contraband is detected, the scanner automatically notifies nearby guards and high-ranking players
- **Sound Effects**: Optional audio alerts for contraband detection
- **Visual Indicators**: Contraband items are marked with special [⚠] indicators in scan results

Configure contraband in `weapon_scanner_config.lua`:
```lua
WEAPON_SCANNER_CONTRABAND = {
    "weapon_rpg",
    "weapon_frag",
    "ls_lightsaber"
}
```

### 2. Stealth and Anti-Detection Mechanics
The system supports stealth roles and cloaking technology:
- **Stealth Roles**: Certain roles (e.g., Sith Assassins, Spies) can bypass scanner detection
- **Stealth Teams**: Entire teams can be configured for scanner immunity
- **Cloaking Device SWEP**: A special weapon that spoofs scans, showing "Empty pockets" instead of actual weapons

Configure stealth roles and teams in `weapon_scanner_config.lua`:
```lua
WEAPON_SCANNER_STEALTH_ROLES = {
    ["SithAssassin"] = true,
    ["Spy"] = true
}

WEAPON_SCANNER_STEALTH_TEAMS = {
    [TEAM_SITHSPY] = true,
    [TEAM_BOUNTYHUNTER] = true
}
```

### 3. Customized Scan Messages
Scan results are now more immersive and informative:
- **Clear Categories**: Weapons are organized into "ALLOWED" and "BLACKLISTED" sections
- **Custom Messages**: All scan messages can be personalized for your server theme
- **Sound Effects**: Optional scan sounds for enhanced immersion
- **Contraband Indicators**: Special markers for critical contraband items

Example scan output:
```
[SCANNING...]
=== Scan Results for [PlayerName] ===
⚠ CRITICAL CONTRABAND DETECTED ⚠
BLACKLISTED ITEMS:
  [⚠] weapon_rpg
  [!] weapon_frag
ALLOWED ITEMS:
  [✓] weapon_physgun
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
   - Scans weapons being carried by individuals to ensure compliance with security protocols.
   - Detects contraband items and alerts nearby guards
   - Categorizes weapons into allowed and blacklisted items
2. **Weapon Confiscation**:
   - Confiscate prohibited items securely and log the details for review.
3. **Authentication Integration**:
   - Validate the authority level of the scanning personnel.
4. **Stealth Mechanics**:
   - Stealth roles can bypass scanner detection
   - Cloaking devices can spoof scan results
5. **Customizable Alerts**:
   - Configure contraband alerts with sound effects
   - Notify authorized personnel within a configurable radius

### Roleplay Guidelines
- Always treat scanned individuals with respect and adhere to community rules.
- Ensure that scanning and confiscation actions are logged for transparency and accountability purposes.
- Use the scanner and confiscator tools sparingly to avoid disrupting RP flow unnecessarily.

### Important Notes
The use of the Weapon Scanning System is not only a matter of enforcement but also a significant contributor to creating an immersive and authentic RP experience. Guards play an essential part in setting the tone of the RP environment and reinforcing the rules of the community.

## Development
If you encounter an issue or have suggestions for improvements, feel free to open an issue or submit a pull request. Your contributions help make this system even better for everyone!

---

Thank you for using the CWRP Weapon Scanning System. Together, we can build a secure and engaging roleplay experience.