-- Enhanced Weapon Sling Client Script by Veyjon!

local attachedBackProp = nil
local attachedFrontProp = nil
local isWeaponSlung = false
local isFrontWeaponSlung = false
local lastSlungWeaponHash = nil
local lastFrontSlungWeaponHash = nil

-- Attach weapon to back
function AttachWeaponPropToBack(propModel)
    if attachedBackProp and DoesEntityExist(attachedBackProp) then
        DeleteObject(attachedBackProp)
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    local modelHash = GetHashKey(propModel)
    
    if not IsModelValid(modelHash) then
        print("Invalid back prop model: " .. tostring(propModel))
        return false
    end
    
    RequestModel(modelHash)
    
    local loadAttempts = 0
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(100)
        loadAttempts = loadAttempts + 1
        
        if loadAttempts > 50 then
            print("Failed to load back prop model: " .. tostring(propModel))
            return false
        end
    end
    
    attachedBackProp = CreateObject(modelHash, coords.x, coords.y, coords.z, true, true, false)
    
    if not DoesEntityExist(attachedBackProp) then
        print("Failed to create back prop object")
        return false
    end
    
    AttachEntityToEntity(
        attachedBackProp,   -- Entity to attach
        ped,                -- Parent entity
        GetPedBoneIndex(ped, 24818),  -- Bone index (upper back)
        -0.0,               -- X offset
        -0.15,              -- Y offset
        -0.02,              -- Z offset
        0.0,                -- X rotation
        35.0,               -- Y rotation
        0.0,                -- Z rotation
        true,              -- Use soft pinning
        false,              -- Is an object
        false,              -- Collision
        false,              -- Teleport
        2,                  -- Attachment point type
        true                -- Can be deleted
    )
    
    SetModelAsNoLongerNeeded(modelHash)
    
    isWeaponSlung = true
    
    return true
end

-- Attach weapon to front
function AttachWeaponPropToFront(propModel)
    if attachedFrontProp and DoesEntityExist(attachedFrontProp) then
        DeleteObject(attachedFrontProp)
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    local modelHash = GetHashKey(propModel)
    
    if not IsModelValid(modelHash) then
        print("Invalid front prop model: " .. tostring(propModel))
        return false
    end
    
    RequestModel(modelHash)
    
    local loadAttempts = 0
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(100)
        loadAttempts = loadAttempts + 1
        
        if loadAttempts > 50 then
            print("Failed to load front prop model: " .. tostring(propModel))
            return false
        end
    end
    
    attachedFrontProp = CreateObject(modelHash, coords.x, coords.y, coords.z, true, true, false)
    
    if not DoesEntityExist(attachedFrontProp) then
        print("Failed to create front prop object")
        return false
    end
    
    AttachEntityToEntity(
        attachedFrontProp,  -- Entity to attach
        ped,                -- Parent entity
        GetPedBoneIndex(ped, 24817),  -- Bone index (chest)
        0.05,               -- X offset
        0.18,               -- Y offset
        -0.04,               -- Z offset
        -10.0,              -- X rotation
        330.0,              -- Y rotation
        180.0,              -- Z rotation
        true,              -- Use soft pinning
        false,              -- Is an object
        false,              -- Collision
        false,              -- Teleport
        2,                  -- Attachment point type
        true                -- Can be deleted
    )
    
    SetModelAsNoLongerNeeded(modelHash)
    
    isFrontWeaponSlung = true
    
    return true
end

-- Remove weapon from back
function RemoveBackWeaponProp()
    if attachedBackProp and DoesEntityExist(attachedBackProp) then
        DeleteObject(attachedBackProp)
        attachedBackProp = nil
    end
    
    isWeaponSlung = false
end

-- Remove weapon from front
function RemoveFrontWeaponProp()
    if attachedFrontProp and DoesEntityExist(attachedFrontProp) then
        DeleteObject(attachedFrontProp)
        attachedFrontProp = nil
    end
    
    isFrontWeaponSlung = false
end

-- Unsling both weapons
function RemoveBothWeaponProps()
    RemoveBackWeaponProp()
    RemoveFrontWeaponProp()
end

RegisterCommand('sling', function()
    local ped = PlayerPedId()
    local currentWeapon = GetSelectedPedWeapon(ped)
    
    -- Check if already slung (either back or front)
    if isWeaponSlung or isFrontWeaponSlung then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Sling", "You already have a weapon slung!"}
        })
        return
    end
    
    local propModel = nil
    for weaponName, prop in pairs(Config.SlingProps) do
        if GetHashKey(weaponName) == currentWeapon then
            propModel = prop
            lastSlungWeaponHash = currentWeapon  
            break
        end
    end
    
    if not propModel then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Sling", "This weapon cannot be slung!"}
        })
        return
    end
    
    if Config.ExcludedWeapons[GetWeaponNameFromHash(currentWeapon)] then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Sling", "This weapon type is excluded from slinging!"}
        })
        return
    end
    
    -- Attach weapon to back
    if AttachWeaponPropToBack(propModel) then
        SetCurrentPedWeapon(ped, GetHashKey('weapon_unarmed'), true)
        
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            multiline = true,
            args = {"Sling", "Weapon slung to back successfully!"}
        })
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Sling", "Failed to sling weapon!"}
        })
    end
end)

RegisterCommand('unsling', function()
    -- Unsling both
    if not isWeaponSlung and not isFrontWeaponSlung then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Unsling", "You have no weapon slung!"}
        })
        return
    end
    
    RemoveBothWeaponProps()
    
    local ped = PlayerPedId()
    
    if lastSlungWeaponHash and HasPedGotWeapon(ped, lastSlungWeaponHash, false) then
        SetCurrentPedWeapon(ped, lastSlungWeaponHash, true)
    end
    
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        multiline = true,
        args = {"Unsling", "Weapon unslung successfully!"}
    })
end)

-- New Sling Front Command
RegisterCommand('slingfront', function()
    local ped = PlayerPedId()
    local currentWeapon = GetSelectedPedWeapon(ped)
    
    -- Check if already slung (either back or front)
    if isWeaponSlung or isFrontWeaponSlung then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Sling Front", "You already have a weapon slung!"}
        })
        return
    end
    
    local propModel = nil
    for weaponName, prop in pairs(Config.SlingProps) do
        if GetHashKey(weaponName) == currentWeapon then
            propModel = prop
            lastFrontSlungWeaponHash = currentWeapon  
            break
        end
    end
    
    if not propModel then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Sling Front", "This weapon cannot be slung!"}
        })
        return
    end
    
    if Config.ExcludedWeapons[GetWeaponNameFromHash(currentWeapon)] then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Sling Front", "This weapon type is excluded from slinging!"}
        })
        return
    end
    
    -- Attach weapon to front
    if AttachWeaponPropToFront(propModel) then
        SetCurrentPedWeapon(ped, GetHashKey('weapon_unarmed'), true)
        
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            multiline = true,
            args = {"Sling Front", "Weapon slung to front successfully!"}
        })
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Sling Front", "Failed to sling weapon!"}
        })
    end
end)

-- New Unsling Front Command
RegisterCommand('unslingfront', function()
    if not isFrontWeaponSlung then
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Unsling Front", "You have no weapon slung to the front!"}
        })
        return
    end
    
    RemoveFrontWeaponProp()
    
    local ped = PlayerPedId()
    
    if lastFrontSlungWeaponHash and HasPedGotWeapon(ped, lastFrontSlungWeaponHash, false) then
        SetCurrentPedWeapon(ped, lastFrontSlungWeaponHash, true)
    end
    
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        multiline = true,
        args = {"Unsling Front", "Weapon unslung from front successfully!"}
    })
end)

function GetWeaponNameFromHash(hash)
    for weaponName, _ in pairs(Config.SlingProps) do
        if GetHashKey(weaponName) == hash then
            return weaponName
        end
    end
    return nil
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() == resourceName) then
        RemoveBothWeaponProps()
    end
end)
