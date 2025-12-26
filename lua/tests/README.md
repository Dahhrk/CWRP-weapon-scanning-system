# Configuration Validation Tests

This directory contains validation scripts to help server administrators verify their CWRP Weapon Scanning System configuration.

## validate_config.lua

A comprehensive validation script that checks your `weapon_scanner_config.lua` file for common errors and configuration issues.

### What It Checks

1. **Configuration Loading**: Verifies the configuration file is loaded
2. **Required Tables**: Ensures all required configuration tables exist
3. **Danger Levels**: Validates danger level values are "green", "yellow", or "red"
4. **Item-Job Exceptions**: Checks job exception values are valid
5. **Concealment Settings**: Validates concealment configuration structure
6. **Systematic Scanning**: Validates scanning configuration structure
7. **Messages**: Checks required messages are defined
8. **SWEP Permissions**: Validates SWEP team permission structure

### How to Use

#### Method 1: Manual Run (Recommended for Testing)

1. Start your Garry's Mod server
2. Open the server console
3. Run the command:
   ```
   lua_run include("lua/tests/validate_config.lua")
   ```
4. Review the output for any errors or warnings

#### Method 2: Automatic Run on Server Start

1. Copy `validate_config.lua` to `lua/autorun/server/` directory
2. Rename it to something like `0_validate_config.lua` (prefix with 0 to run first)
3. Start your server
4. Validation will run automatically and output to console

#### Method 3: One-Time Test

1. Open the file directly in your Lua console
2. Copy the entire contents
3. Paste and run in server console

### Understanding Results

#### ✓ All Checks Passed
Your configuration is valid and ready to use!

#### ⚠ Warnings
Non-critical issues that should be reviewed:
- Missing optional settings
- Empty SWEP permission tables (might be intentional)
- Undefined optional message strings

Warnings won't prevent the addon from working but may indicate incomplete configuration.

#### ❌ Errors
Critical issues that must be fixed:
- Missing required tables
- Invalid danger level values (not "green", "yellow", or "red")
- Invalid job exception values
- Wrong data types for settings

Errors may cause the addon to malfunction and must be corrected.

### Example Output

```
================================================================================
CWRP Weapon Scanning System - Configuration Validator
================================================================================

[1/8] Checking if configuration is loaded...
  ✓ Configuration appears to be loaded

[2/8] Checking required configuration tables...
  ✓ WEAPON_SCANNER_JOB_BYPASS exists
  ✓ ITEM_DANGER_LEVELS exists
  ✓ ITEM_JOB_EXCEPTIONS exists
  ✓ WEAPON_SCANNER_CONCEALMENT exists
  ✓ WEAPON_SCANNER_SYSTEMATIC exists
  ✓ WEAPON_SCANNER_MESSAGES exists
  ✓ SWEP_ALLOWED_TEAMS exists

[3/8] Validating danger level values...
  ✓ Checked 13 danger level entries

[4/8] Validating item-job exceptions...
  ✓ Checked 0 job exception entries

[5/8] Validating concealment configuration...
  ✓ Concealment configuration structure is valid

[6/8] Validating systematic scanning configuration...
  ✓ Systematic scanning configuration structure is valid

[7/8] Validating messages configuration...
  ✓ Messages configuration structure is valid

[8/8] Validating SWEP team permissions...
  ✓ SWEP permissions structure is valid

================================================================================
VALIDATION RESULTS
================================================================================

✓✓✓ ALL VALIDATION CHECKS PASSED! ✓✓✓
Your configuration is valid and ready to use.

================================================================================
```

### Troubleshooting

**"Configuration not loaded" warning**
- The config file hasn't been loaded yet
- Make sure the validator runs after the main addon loads
- Try renaming to run later in autorun sequence

**Multiple errors about missing tables**
- Your config file has syntax errors preventing it from loading
- Check for missing commas, brackets, or quotes
- Review the config file for Lua syntax issues

**"Invalid danger level value" errors**
- You have typos in danger level assignments
- Valid values are exactly: "green", "yellow", "red" (lowercase)
- Check spelling and ensure values are quoted strings

## Adding New Validation Tests

To add new validation checks:

1. Open `validate_config.lua`
2. Add a new test section following the existing pattern
3. Use `AddError()` for critical issues
4. Use `AddWarning()` for non-critical issues
5. Print progress messages to help admins understand what's being checked

## Support

For issues with validation or configuration:
- See `CONFIG_GUIDE.md` for detailed configuration help
- Check `README.md` for feature documentation
- Review `EXAMPLES.md` for configuration examples
