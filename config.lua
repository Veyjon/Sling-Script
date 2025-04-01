Config = {}

Config.ExcludedWeapons = {
    -- Pistols
    ["weapon_pistol"] = true,
    ["weapon_pistol_mk2"] = true,
    ["weapon_revolver"] = true,
    ["weapon_revolver_mk2"] = true,
    ["weapon_snspistol"] = true,
    ["weapon_snspistol_mk2"] = true,
    ["weapon_combatpistol"] = true,
    ["weapon_appistol"] = true,
    ["weapon_ceramicpistol"] = true,
    ["weapon_heavypistol"] = true,
    ["weapon_doubleaction"] = true,
    ["weapon_vistagepistol"] = true,
    ["weapon_marksmanpistol"] = true,
    ["weapon_navyrevolver"] = true,
    ["weapon_flaregun"] = true,

    -- Stabby/hit
    ["weapon_knife"] = true,
    ["weapon_nightstick"] = true,
    ["weapon_hammer"] = true,
    ["weapon_crowbar"] = true,
    ["weapon_golfclub"] = true,
    ["weapon_bottle"] = true,
    ["weapon_dagger"] = true,
    ["weapon_hatchet"] = true,
    ["weapon_machete"] = true,
    ["weapon_switchblade"] = true,
    ["weapon_battleaxe"] = true,
    ["weapon_poolcue"] = true,
    ["weapon_wrench"] = true,
    ["weapon_bread"] = true,

    -- COD Zombies
    ["weapon_stungun"] = true,
    ["weapon_raypistol"] = true,

    -- Explosives
    ["weapon_grenade"] = true,
    ["weapon_bzgas"] = true,
    ["weapon_molotov"] = true,
    ["weapon_proxmine"] = true,
    ["weapon_pipebomb"] = true,
    ["weapon_smokegrenade"] = true,

    -- Special Ed
    ["weapon_petrolcan"] = true,
    ["weapon_fireextinguisher"] = true,
    ["weapon_parachute"] = true,

    -- DLC Weapons
    ["weapon_rayminigun"] = true,
    ["weapon_railgun"] = true
}

Config.SlingProps = {
    -- Rifles
    ["weapon_carbinerifle"] = "w_ar_carbinerifle",
    ["weapon_carbinerifle_mk2"] = "w_ar_carbinerifle_mk2",
    ["weapon_assaultrifle"] = "w_ar_assaultrifle",
    ["weapon_assaultrifle_mk2"] = "w_ar_assaultrifle_mk2",
    ["weapon_advancedrifle"] = "w_ar_advancedrifle",
    ["weapon_specialcarbine"] = "w_ar_specialcarbine",
    ["weapon_specialcarbine_mk2"] = "w_ar_specialcarbine_mk2",
    ["weapon_bullpuprifle"] = "w_ar_bullpuprifle",
    ["weapon_bullpuprifle_mk2"] = "w_ar_bullpuprifle_mk2",
    ["weapon_compactrifle"] = "w_ar_compactrifle",
    ["weapon_militaryrifle"] = "w_ar_militaryrifle",
    ["weapon_tacticalrifle"] = "w_ar_assaultrifle",
    ["weapon_servicecarbine"] = "w_ar_assaultrifle",

    -- Shotguns
    ["weapon_pumpshotgun"] = "w_sg_pumpshotgun",
    ["weapon_pumpshotgun_mk2"] = "w_sg_pumpshotgun",
    ["weapon_heavyshotgun"] = "w_sg_heavyshotgun",
    ["weapon_bullpupshotgun"] = "w_sg_bullpupshotgun",
    ["weapon_sawnoffshotgun"] = "w_sg_sawnoff",
    ["weapon_assaultshotgun"] = "w_sg_assaultshotgun",
    ["weapon_doublebarrelshotgun"] = "w_sg_doublebarrel",
    ["weapon_combatshotgun"] = "w_sg_pumpshotgun",

    -- Sniper Rifles
    ["weapon_sniperrifle"] = "w_sr_sniperrifle",
    ["weapon_heavysniper"] = "w_sr_heavysniper",
    ["weapon_heavysniper_mk2"] = "w_sr_heavysniper_mk2",
    ["weapon_marksmanrifle"] = "w_sr_marksmanrifle",
    ["weapon_marksmanrifle_mk2"] = "w_sr_marksmanrifle_mk2",

    -- Machine Guns
    ["weapon_mg"] = "w_mg_mg",
    ["weapon_combatmg"] = "w_mg_combatmg",
    ["weapon_combatmg_mk2"] = "w_mg_combatmg_mk2",
    ["weapon_minigun"] = "w_mg_minigun",

    -- Melee Weapon
    ["weapon_bat"] = "w_me_bat"
}

for weaponName, propModel in pairs(Config.CustomWeapons or {}) do
    Config.SlingProps[weaponName] = propModel
end

local function log(message, isError)
    local color = isError and {255, 0, 0} or {0, 255, 0}
    TriggerEvent("chat:addMessage", {
        color = color,
        multiline = true,
        args = {"Sling System", message}
    })
    
    if SERVER then
        print("Sling System: " .. message)
    end
end

local SlungWeapons = {}

RegisterCommand("sling", function(source, args, rawCommand)
    local ped = PlayerPedId() 
    local weaponHash = GetSelectedPedWeapon(ped)
    
    if weaponHash == -1569615261 then 
        return log("You must have a weapon equipped to sling.", true)
    end
    
    local weaponName = nil
    for name, _ in pairs(Config.SlingProps) do
        if GetHashKey(name) == weaponHash then
            weaponName = name
            break
        end
    end
    
    if not weaponName or Config.ExcludedWeapons[weaponName] then
        return log("This weapon cannot be slung!", true)
    end
    
    if SlungWeapons[source] then
        return log("You already have a weapon slung!", true)
    end
    
    local components = {}
    local componentHashes = {
        "COMPONENT_AT_PI_FLSH", "COMPONENT_AT_AR_FLSH", "COMPONENT_AT_PI_SUPP", 
        "COMPONENT_AT_AR_SUPP", "COMPONENT_AT_PI_COMP", "COMPONENT_AT_AR_SUPP_2",
        "COMPONENT_AT_SCOPE_MACRO", "COMPONENT_AT_SCOPE_MEDIUM", "COMPONENT_AT_SCOPE_LARGE",
        "COMPONENT_AT_SCOPE_MAX", "COMPONENT_AT_SCOPE_SMALL", "COMPONENT_AT_SCOPE_MACRO_2"
    }
    
    for _, componentHash in ipairs(componentHashes) do
        local hash = GetHashKey(componentHash)
        if HasPedGotWeaponComponent(ped, weaponHash, hash) then
            table.insert(components, hash)
        end
    end
    
    local propModel = Config.SlingProps[weaponName]
    if propModel then
        log("Slung weapon: " .. (weaponName or "Unknown"))
        
        SlungWeapons[source] = {
            weapon = weaponHash,
            components = components,
            propModel = propModel,
            ammo = GetAmmoInPedWeapon(ped, weaponHash)
        }
        
        RemoveWeaponFromPed(ped, weaponHash)
    else
        log("No prop found for this weapon.", true)
    end
end, false)

RegisterCommand("unsling", function(source, args, rawCommand)
    local ped = PlayerPedId()
    local slungWeapon = SlungWeapons[source]
    
    if not slungWeapon then
        return log("You have no weapon slung!", true)
    end
    
    GiveWeaponToPed(ped, slungWeapon.weapon, slungWeapon.ammo, false, true)
    
    for _, componentHash in ipairs(slungWeapon.components) do
        GiveWeaponComponentToPed(ped, slungWeapon.weapon, componentHash)
    end
    
    SlungWeapons[source] = nil
    
    log("Weapon unslung successfully with attachments.")
end, false)

local SlungFrontWeapons = {}

RegisterCommand("slingfront", function(source, args, rawCommand)
    local ped = PlayerPedId() 
    local weaponHash = GetSelectedPedWeapon(ped)
    
    if weaponHash == -1569615261 then 
        return log("You must have a weapon equipped to sling to the front.", true)
    end
    
    local weaponName = nil
    for name, _ in pairs(Config.SlingProps) do
        if GetHashKey(name) == weaponHash then
            weaponName = name
            break
        end
    end
    
    if not weaponName or Config.ExcludedWeapons[weaponName] then
        return log("This weapon cannot be slung to the front!", true)
    end
    
    if SlungFrontWeapons[source] then
        return log("You already have a weapon slung to the front!", true)
    end
    
    -- Check if the player already has a weapon slung (using the original SlungWeapons)
    if SlungWeapons[source] then
        return log("You already have a weapon slung at the back!", true)
    end
    
    local components = {}
    local componentHashes = {
        "COMPONENT_AT_PI_FLSH", "COMPONENT_AT_AR_FLSH", "COMPONENT_AT_PI_SUPP", 
        "COMPONENT_AT_AR_SUPP", "COMPONENT_AT_PI_COMP", "COMPONENT_AT_AR_SUPP_2",
        "COMPONENT_AT_SCOPE_MACRO", "COMPONENT_AT_SCOPE_MEDIUM", "COMPONENT_AT_SCOPE_LARGE",
        "COMPONENT_AT_SCOPE_MAX", "COMPONENT_AT_SCOPE_SMALL", "COMPONENT_AT_SCOPE_MACRO_2"
    }
    
    for _, componentHash in ipairs(componentHashes) do
        local hash = GetHashKey(componentHash)
        if HasPedGotWeaponComponent(ped, weaponHash, hash) then
            table.insert(components, hash)
        end
    end
    
    local propModel = Config.SlingProps[weaponName]
    if propModel then
        log("Slung weapon to front: " .. (weaponName or "Unknown"))
        
        SlungFrontWeapons[source] = {
            weapon = weaponHash,
            components = components,
            propModel = propModel,
            ammo = GetAmmoInPedWeapon(ped, weaponHash)
        }
        
        RemoveWeaponFromPed(ped, weaponHash)
    else
        log("No prop found for this weapon.", true)
    end
end, false)

RegisterCommand("unslingfront", function(source, args, rawCommand)
    local ped = PlayerPedId()
    local slungFrontWeapon = SlungFrontWeapons[source]
    
    if not slungFrontWeapon then
        return log("You have no weapon slung to the front!", true)
    end
    
    GiveWeaponToPed(ped, slungFrontWeapon.weapon, slungFrontWeapon.ammo, false, true)
    
    for _, componentHash in ipairs(slungFrontWeapon.components) do
        GiveWeaponComponentToPed(ped, slungFrontWeapon.weapon, componentHash)
    end
    
    SlungFrontWeapons[source] = nil
    
    log("Weapon unslung from front successfully with attachments.")
end, false)

-- Optional: If you want to prevent sling and slingfront from being used simultaneously
local function canSling(source)
    return not SlungWeapons[source] and not SlungFrontWeapons[source]
end