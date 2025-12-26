-- Configuration for CWRP Weapon Scanning System

ENABLE_SERVER_CONSOLE_LOGGING = true

WEAPON_SCANNER_WHITELIST = {"weapon_physgun", "gmod_tool"}
WEAPON_SCANNER_BLACKLIST = {"weapon_rpg", "weapon_frag"}
WEAPON_SCANNER_ROLE_BYPASS = {
    ["VIP"] = true,
    ["Sith"] = true
}