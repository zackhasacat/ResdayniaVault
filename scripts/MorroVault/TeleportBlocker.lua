local _, world = pcall(require, "openmw.world")
local _, util = pcall(require, "openmw.util")
local _, types = pcall(require, "openmw.types")
local _, I = pcall(require, "openmw.interfaces")

local player
local lastCell
local lastPos
local wasInRes = false
local doorIsOpen = false
local antiCheese = true
local RESDAYNIA_SANCTUARY = "Resdaynia Sanctuary"
local ENTRANCE = RESDAYNIA_SANCTUARY .. ", Entrance"
local POSITION_THRESHOLD = 11318  -- Positional boundary to detect significant movement in or out of the vault entrance
local VAULT_POSITION = util.vector3(9726.462890625, 4234.05419921875, 11393) -- Last safe position inside the vault
local storedValues = {}
local questsToCancel = {"TR_dbAttack","A2_2_6thHouse"}
local function startsWith(inputString, startString)
    return string.sub(inputString, 1, string.len(startString)) == startString
end

local function kickPlayerOut()
    player:teleport(ENTRANCE, VAULT_POSITION)
end
local function bringPlayerBack()
    player:teleport(lastCell, lastPos)
end

local function isInVault(actor)
    local cellName = actor.cell.name
    if cellName == ENTRANCE then
        if player.position.x > POSITION_THRESHOLD then
            return true
        else
            return false
        end
    end
    if startsWith(cellName, RESDAYNIA_SANCTUARY) then
        return true
    end
end
local function enterVaultMode()
    world.players[1]:sendEvent("showPlayerMessage","Enter Vault")
    if not storedValues then
        storedValues = {}
    end
    for index, value in ipairs(questsToCancel) do
        storedValues[value] = types.Player.quests(world.players[1])[value].stage
        types.Player.quests(world.players[1])[value].stage = 100
    end
end
local function exitVaultMode()
    world.players[1]:sendEvent("showPlayerMessage","Exit Vault")
    for index, value in ipairs(questsToCancel) do
        local val = storedValues[value]
        types.Player.quests(world.players[1])[value].stage = val
    end
    
end
local function handleCellTransition(cell)
    local cellName = cell.name

    if isInVault(player) then
        if not wasInRes then  -- Player just entered the vault legally or via noclip
            if not doorIsOpen and antiCheese then  -- Handle unexpected entrance
                kickPlayerOut()
            else
                types.Player.setTeleportingEnabled(player, false)
                wasInRes = true
                enterVaultMode()
            end
        end
    else
        if wasInRes then  -- Player is leaving or has left the vault
            types.Player.setTeleportingEnabled(player, true)
            wasInRes = false
            exitVaultMode()
        end
    end
end

local function onCellChange(newCell, oldCell)
 --   print("New cell: " .. newCell.name .. " from old cell: " .. (oldCell and oldCell.name or "none"))
    handleCellTransition(newCell)
    lastCell = newCell
end

local function onUpdate()
    if not player or not player.cell then
        player = world.players[1]
        if not player then return end
    end

    -- Additional checks for position to handle noclip or similar cheats
    if isInVault(player) and not wasInRes then
        -- If player suddenly appears in vault without proper transition
        if not doorIsOpen and antiCheese then
            kickPlayerOut()
            return
        else
            types.Player.setTeleportingEnabled(player, false)
            wasInRes = true
            enterVaultMode()
        end
    elseif not isInVault(player) and wasInRes and player.cell.name ~= ENTRANCE then
        bringPlayerBack()
        return
    end

    -- Check the player's position at the vault entrance against the threshold
    if player.cell.name == ENTRANCE and player.position.x > POSITION_THRESHOLD and not wasInRes then
        types.Player.setTeleportingEnabled(player, false)
        wasInRes = true
        if doorIsOpen then
            I.MorroVault.autoClose()
            return
        end
    elseif player.cell.name == ENTRANCE and player.position.x <= POSITION_THRESHOLD and wasInRes then
        if not doorIsOpen then
            bringPlayerBack()
            return
        else
            if doorIsOpen then
                I.MorroVault.autoClose()
            end
        end
        
        exitVaultMode()
        types.Player.setTeleportingEnabled(player, true)
        wasInRes = false
    end

    if player.cell ~= lastCell then
        onCellChange(player.cell, lastCell)
    end
    lastPos = player.position
end

return {
    interfaceName = "TeleportBlocker",
    interface = {
        setDoorOpen = function(state)
            doorIsOpen = state
        end,
        isInVault= function ()
            return isInVault(player)
        end
    },
    engineHandlers = {
        onUpdate = onUpdate,
        onSave = function()
            return { wasInRes = wasInRes, doorIsOpen = doorIsOpen, storedValues = storedValues, }
        end,
        onLoad = function(data)
            if data then
                wasInRes = data.wasInRes
                doorIsOpen = data.doorIsOpen
                storedValues = data.storedValues
            end
        end
    }
}
