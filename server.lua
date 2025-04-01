-- Weapon Sling Server Script


local PlayerSlungWeapons = {}


RegisterServerEvent('sling:attemptSling')
AddEventHandler('sling:attemptSling', function(weaponHash)
    local source = source
    
    
    if CanPlayerSlingWeapon(source, weaponHash) then
        
        local propModel = GetPropModelForWeapon(weaponHash)
        
        if propModel then
            
            PlayerSlungWeapons[source] = {
                weapon = weaponHash,
                prop = propModel
            }
            
            
            TriggerClientEvent('sling:attachProp', source, propModel)
        end
    end
end)


RegisterServerEvent('sling:attemptUnsling')
AddEventHandler('sling:attemptUnsling', function()
    local source = source
    
    if PlayerSlungWeapons[source] then
        
        PlayerSlungWeapons[source] = nil
        
        
        TriggerClientEvent('sling:removeProp', source)
    end
end)


function CanPlayerSlingWeapon(source, weaponHash)
    
    
    return true
end

function GetPropModelForWeapon(weaponHash)
    
    for weaponName, propModel in pairs(Config.SlingProps) do
        if GetHashKey(weaponName) == weaponHash then
            return propModel
        end
    end
    return nil
end