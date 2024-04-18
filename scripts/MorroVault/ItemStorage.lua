local _, world = pcall(require, "openmw.world")
local isOpenMW, I = pcall(require, "openmw.interfaces")

local _, util = pcall(require, "openmw.util")
local _, core = pcall(require, "openmw.core")
local _, types = pcall(require, "openmw.types")
local anim = require('openmw.animation')

local storedEquip = {}
local storedEquip2 = {}

local function getStorageContainer()
    local cellList = world.getCellByName("Resdaynia Sanctuary, Entrance"):getAll(types.Container)
    for index, value in ipairs(cellList) do
        if value.recordId == "zhac_bchest_outside" then
            return value
        end
    end
end
local function getStorageContainer2()
    local cellList = world.getCellByName("Resdaynia Sanctuary, Entrance"):getAll(types.Container)
    for index, value in ipairs(cellList) do
        if value.recordId == "zhac_bchest_inside" then
            return value
        end
    end
end
local function equipmentToStored(actor)
    local eq = types.Actor.equipment(actor)
    local ids = {}
    for key, value in pairs(eq) do
        ids[key] = value.recordId
    end
    return ids
end

local function getObjByID(id, cell)
    if not cell then
        cell = world.players[1].cell
    end
    for index, value in ipairs(cell:getAll()) do
        if value.recordId == id then
            return value
        end
    end
end
local function onItemActive(item)
    local player = world.players[1]
    if item.recordId == "zhac_vault_itemstoremarker1" then
        --store belongings
        world.mwscript.getGlobalVariables(player).zhac_vault_invstate = 1
        storedEquip = equipmentToStored(player)
        local container = getStorageContainer()
        if container then
            for index, value in ipairs(types.Actor.inventory(player):getAll()) do
                value:moveInto(container)
            end
        end
        getObjByID("zhac_vault_door"):sendEvent("setCutsceneState",1)
    elseif item.recordId == "zhac_vault_itemstoremarker2" then
        --retrive
        world.mwscript.getGlobalVariables(player).zhac_vault_invstate = 0

        local container = getStorageContainer()
        if container then
            for index, value in ipairs(types.Actor.inventory(container):getAll()) do
                value:moveInto(player)
            end
        end
        player:sendEvent("setEquipment",storedEquip)
        storedEquip = {}
    elseif item.recordId == "zhac_vault_itemstoremarker3" then
        --store belongings
        world.mwscript.getGlobalVariables(player).zhac_vault_invstate2 = 1
        storedEquip2 = equipmentToStored(player)
        local container = getStorageContainer2()
        if container then
            for index, value in ipairs(types.Actor.inventory(player):getAll()) do
                value:moveInto(container)
            end
        end
    elseif item.recordId == "zhac_vault_itemstoremarker4" then
        --retrive
        world.mwscript.getGlobalVariables(player).zhac_vault_invstate2 = 0

        local container = getStorageContainer2()
        if container then
            for index, value in ipairs(types.Actor.inventory(container):getAll()) do
                value:moveInto(player)
            end
        end
        player:sendEvent("setEquipment",storedEquip2)
        storedEquip2 = {}
    else
        return
    end
    item:remove()
end

local function onSave()
    return { storedEquip = storedEquip, storedEquip2 = storedEquip2 }
end
local function onLoad(data)
    if data then
        storedEquip = data.storedEquip
        storedEquip2 = data.storedEquip2
    end
end

return
{
    engineHandlers = {
        onItemActive = onItemActive,
        onLoad = onLoad,
        onSave = onSave,
    }
}
