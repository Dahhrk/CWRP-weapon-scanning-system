# CWRP Weapon Scanning System - Configuration Guide

## Overview

This guide helps server administrators understand and customize the CWRP Weapon Scanning System configuration file located at `lua/config/weapon_scanner_config.lua`.

## Quick Start

The configuration file comes with production-ready default values that work out-of-the-box. You can use the system immediately without any changes.

### Minimum Required Changes

Before deploying to your server, you should:

1. **Update Team Constants**: Replace `TEAM_SHOCK`, `TEAM_TEMPLEGUARD`, etc. with your server's actual team constants
2. **Configure Job Bypass**: Uncomment and set which jobs should bypass scanning
3. **Set Danger Levels**: Add your custom weapons to `ITEM_DANGER_LEVELS`

## Configuration File Structure

The configuration file is organized into 11 clear sections:

### Section 1: General Settings
- `ENABLE_SERVER_CONSOLE_LOGGING`: Controls debug logging to console

### Section 2: Legacy Settings (Deprecated)
- `WEAPON_SCANNER_WHITELIST`: Old whitelist system (use danger levels instead)
- `WEAPON_SCANNER_BLACKLIST`: Old blacklist system (use danger levels instead)
- `WEAPON_SCANNER_ROLE_BYPASS`: Old role bypass (use job bypass instead)

### Section 3: Job-Based Bypass Configuration
- `WEAPON_SCANNER_JOB_BYPASS`: Modern job/team bypass system
- Replaces deprecated Cloaking Device SWEP

### Section 4: Contraband & Legacy Alert Configuration
- `WEAPON_SCANNER_CONTRABAND`: Critical contraband list
- `WEAPON_SCANNER_CONTRABAND_ALERTS`: Alert settings for guards

### Section 5: Deprecated Stealth Configuration
- `WEAPON_SCANNER_STEALTH_ROLES`: Old stealth roles (deprecated)
- `WEAPON_SCANNER_STEALTH_TEAMS`: Old stealth teams (deprecated)

### Section 6: Danger Level System
- `ITEM_DANGER_LEVELS`: Modern color-coded threat level system
  - Green: Low threat (tools, medical supplies)
  - Yellow: Questionable (basic weapons, lockpicks)
  - Red: High danger (explosives, heavy weapons)

### Section 7: Item-Job Exception System
- `ITEM_JOB_EXCEPTIONS`: Job-specific item permissions
- Override default danger levels per job

### Section 8: Concealment System Configuration
- `WEAPON_SCANNER_CONCEALMENT`: Player item concealment settings
  - enabled: Toggle concealment system
  - maxConcealedSlots: How many items can be hidden
  - concealTime: Base time to conceal
  - Multipliers for large/dangerous items
  - List of unconcealable items

### Section 9: Systematic Scanning Configuration
- `WEAPON_SCANNER_SYSTEMATIC`: Progressive scanning behavior
  - enabled: Toggle slot-by-slot scanning
  - slotDelay: Time between scanning each slot
  - showProgress: Show scan progress messages
  - cancelOnMove: Cancel if target moves
  - maxScanDistance: Maximum distance for scanning

### Section 10: Messages & UI Customization
- `WEAPON_SCANNER_MESSAGES`: All text messages and notifications
  - Scan flow messages
  - Category headers
  - Alert messages
  - Sound effects

### Section 11: SWEP Team Permissions
- `SWEP_ALLOWED_TEAMS`: Which teams can use each SWEP
  - weapon_scanner
  - weapon_confiscator
  - weapon_drop
  - weapon_bypass_scanning_swep (deprecated)
- `SWEP_STRIP_DELAY`: Delay before removing unauthorized SWEP

## Common Customization Scenarios

### Scenario 1: Adding Custom Weapons

Add your custom weapons to the danger level system:

```lua
ITEM_DANGER_LEVELS = {
    -- ... existing items ...
    
    -- Your custom weapons
    ["tfa_custom_rifle"] = "yellow",
    ["custom_explosive"] = "red",
    ["custom_medkit"] = "green",
}
```

### Scenario 2: Job-Specific Lightsaber Permissions

Configure lightsabers to be allowed for Jedi but contraband for civilians:

```lua
ITEM_JOB_EXCEPTIONS = {
    ["weapon_lightsaber"] = {
        [TEAM_JEDI] = "allowed",
        [TEAM_SITH] = "allowed",
        [TEAM_CIVILIAN] = "red"
    },
}
```

### Scenario 3: Configuring Spy Jobs

Set up spy jobs that cannot be scanned:

```lua
WEAPON_SCANNER_JOB_BYPASS = {
    [TEAM_SITHSPY] = true,
    [TEAM_REBELAGENT] = true,
}
```

### Scenario 4: Adjusting Concealment Difficulty

Make concealment harder (stricter security):

```lua
WEAPON_SCANNER_CONCEALMENT = {
    enabled = true,
    maxConcealedSlots = 1,        -- Only 1 item can be hidden
    concealTime = 5,               -- Takes 5 seconds
    largeItemMultiplier = 3,       -- Large items take 3x longer
    dangerItemMultiplier = 2,      -- Dangerous items take 2x longer
    -- ... rest of settings ...
}
```

Or disable it entirely for maximum security:

```lua
WEAPON_SCANNER_CONCEALMENT = {
    enabled = false,
    -- ... rest of settings ...
}
```

### Scenario 5: Faster Scanning for Busy Servers

Speed up scans for high-traffic checkpoints:

```lua
WEAPON_SCANNER_SYSTEMATIC = {
    enabled = true,
    slotDelay = 0,                 -- Instant scanning (no delay)
    showProgress = false,          -- Less chat spam
    cancelOnMove = false,
    maxScanDistance = 200
}
```

### Scenario 6: Custom Security Teams

Configure different teams for your server:

```lua
SWEP_ALLOWED_TEAMS = {
    ["weapon_scanner"] = {
        TEAM_POLICE,
        TEAM_SWAT,
        TEAM_SECURITY,
        TEAM_MILITARY
    },
    -- ... rest of SWEPs ...
}
```

## Validation Checklist

Before deploying your configuration changes:

- [ ] All TEAM constants are defined by your gamemode
- [ ] Weapon class names are spelled correctly (case-sensitive)
- [ ] Danger levels use valid values: "green", "yellow", "red", "allowed"
- [ ] Tables are properly formatted with commas
- [ ] File ends with valid Lua syntax
- [ ] No duplicate weapon entries
- [ ] Alert teams exist in your gamemode
- [ ] Sound effect paths are valid

## Testing Your Configuration

1. **Syntax Test**: Load the server and check console for Lua errors
2. **Scan Test**: Use weapon_scanner on different jobs to verify danger levels
3. **Bypass Test**: Try scanning jobs configured in WEAPON_SCANNER_JOB_BYPASS
4. **Exception Test**: Scan jobs with item exceptions configured
5. **Concealment Test**: Try concealing items using console commands
6. **Alert Test**: Trigger contraband alerts and verify guards receive them
7. **SWEP Test**: Verify only authorized teams can use SWEPs

## Troubleshooting

### "Team constant not defined" errors
- Your gamemode hasn't loaded team constants yet
- Solution: Use numeric team IDs instead, or ensure gamemode loads first

### Danger levels not showing correctly
- Check weapon class names for typos (case-sensitive)
- Verify ITEM_DANGER_LEVELS table syntax is correct

### Job bypass not working
- Confirm WEAPON_SCANNER_JOB_BYPASS contains correct team ID
- Check that target player is actually on the bypassed team

### Concealment not working
- Ensure WEAPON_SCANNER_CONCEALMENT.enabled = true
- Check item isn't in unconcealableItems list
- Verify player isn't moving during concealment

### SWEP gets removed immediately
- Player's team not in SWEP_ALLOWED_TEAMS for that SWEP
- Add player's team to the allowed teams list

## Advanced Configuration

### Using Numeric Team IDs

If your gamemode doesn't define TEAM constants:

```lua
WEAPON_SCANNER_JOB_BYPASS = {
    [5] = true,    -- Team ID 5
    [12] = true,   -- Team ID 12
}
```

### Custom Alert Messages

Personalize alert messages:

```lua
WEAPON_SCANNER_MESSAGES = {
    dangerAlert = "🚨 SECURITY ALERT: %s found on %s!",
    restrictedAlert = "⚠ WARNING: Unauthorized %s detected on %s",
    -- ... rest of messages ...
}
```

### Multiple Danger Profiles

Create different configuration files for different game modes or maps, then switch between them programmatically.

## Support

For issues or questions:
- Check README.md for feature documentation
- See EXAMPLES.md for detailed usage examples
- Review IMPLEMENTATION_SUMMARY.md for technical details
- Report bugs on the GitHub repository

## Version Information

This configuration guide is for CWRP Weapon Scanning System with:
- Danger Level System
- Item-Job Exceptions
- Job-Based Bypass
- Concealment Mechanics
- Systematic Scanning
- Enhanced Guard Alerts
- Comprehensive Logging

---

*Thank you for using the CWRP Weapon Scanning System!*
