RegisterServerEvent("redemrp_respawn:SaveCoordsFromClient")
AddEventHandler("redemrp_respawn:SaveCoordsFromClient", function(coords) 
    local _source = source

    TriggerEvent('redemrp:getPlayerFromId', _source, function(user,data)
        _id = user.getIdentifier()
        charID = user.getSessionVar("charid")
    end)
    local exstCoords = CheckCoords(_id,charID)

    if not exstCoords then
        CreateCoords(_id,charID,coords)
    else
        UpdateCoords(_id,charID,coords)
    end
end)

RegisterServerEvent("redemrp_respawn:FirstSpawn")
AddEventHandler("redemrp_respawn:FirstSpawn",function()
    local _source = source

    TriggerEvent('redemrp:getPlayerFromId', _source, function(user,data)
        _id = user.getIdentifier()
        charID = user.getSessionVar("charid")
    end)
    GetCoords(_id,charID,_source)
end)

function GetCoords(_id,_characterID,_source)


    MySQL.Async.fetchAll('SELECT * FROM coords WHERE identifier = @id AND characterid = @charid',
    {
        ['@id']   = _id,
        ['@charid'] = _characterID,
    },  function (result)
        if result then 
            for k,v in ipairs(result) do
                local kekw = json.decode(v.coords)
                TriggerClientEvent("redemrp_respawn:FirstSpawnClient",_source,kekw)
            end
        else
            TriggerClientEvent("redemrp_respawn:FirstSpawnClient",_source)
        end

    end)

    
end

function CheckCoords(_id,_characterID)
    local kekCheck = nil
    MySQL.Async.fetchAll('SELECT 1 FROM coords WHERE identifier = @id AND characterid = @charid',
    {
        ['@id']   = _id,
        ['@charid'] = _characterID,
    },  function (result)
        if result then
            kekCheck = true
        else
            kekCheck = false
        end
    end)
    while kekCheck == nil do 
        Wait(500)
    end
    return kekCheck
end

function UpdateCoords(_id,_characterID,coords)
    local kekw = json.encode( {x = coords.x, y = coords.y, z = coords.z})
    MySQL.Async.execute('UPDATE coords SET coords = @coords WHERE identifier = @id AND characterid = @charid', 
    {   
        ['@id']   = _id,
        ['@charid'] = _characterID,
        ['@coords']   = kekw,
    },  function(OMEGAKEK)
        if OMEGAKEK then 
            print('Saving coords Succesfull') -- remove later
        end
    end)
end

function CreateCoords(_id,_characterID,coords)
    local kekw = json.encode({x = coords.x, y = coords.y, z = coords.z})
    MySQL.Async.execute('INSERT INTO coords (identifier, characterid, coords) VALUES (@identifier, @charid, @coords)',
    {
        ['@id']   = _id,
        ['@charid'] = _characterID,
        ['@coords']   = kekw,
    },  function (LULW)
        if LULW then
            print('Coords Created succesfully')
        end
    end)
end