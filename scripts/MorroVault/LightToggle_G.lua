

local world = require("openmw.world")
local I = require("openmw.interfaces")
local util = require("openmw.util")
local core = require("openmw.core")
local types = require("openmw.types")
local async = require("openmw.async")
local anim = require('openmw.animation')
local calendar = require('openmw_aux.calendar')
local time = require('openmw_aux.time')

local createdLightOffRecords = {}
local createdLightOffObjects = {}
local createdLightOnObjects = {}
local function getNearbyById(cell,objId)
    for index, value in ipairs(cell:getAll(types.Light)) do
        if value.id == objId then
            return value
        end
    end
end
local function getOffRecord(recordId)
    if createdLightOffRecords[recordId] then
        return createdLightOffRecords[recordId]
    end
    local newRecordDraft = types.Light.createRecordDraft({template = types.Light.records[recordId], isOffByDefault = true})
    local newRecord = world.createRecord(newRecordDraft)
    createdLightOffRecords[recordId] = newRecord.id
    return newRecord.id
end
local function turnLightOff(obj)
    local record = obj.type.records[obj.recordId]
    if record.isOffByDefault then
        return
    end
    if createdLightOffObjects[obj.id] then
        local offObj = getNearbyById(obj.cell,createdLightOffObjects[obj.id])
        if not offObj then
            error("Unable to find " .. createdLightOffObjects[obj.id])
        end
        offObj.enabled = true
        obj.enabled = false
    else
        local newRecord = getOffRecord(obj.recordId)
        local newObject = world.createObject(newRecord)
        createdLightOffObjects[obj.id] = newObject.id
        createdLightOnObjects[newObject.id] = obj.id
        newObject:teleport(obj.cell,obj.position,obj.rotation)
        obj.enabled = false
    end
end
local function turnLightOn(obj)
    local record = obj.type.records[obj.recordId]
    if not record.isOffByDefault then
        return
    end
    if createdLightOnObjects[obj.id] then
        local onObj = getNearbyById(obj.cell,createdLightOnObjects[obj.id])
        if not onObj then
            error("Unable to find " .. createdLightOnObjects[obj.id])
        end
        onObj.enabled = true
        obj.enabled = false
    else
    --    local newRecord = getOffRecord(obj.recordId)
   --    local newObject = world.createObject(newRecord)
   --     createdLightOffObjects[obj.id] = newObject.id
   --     createdLightOnObjects[newObject.id] = obj.id
   --     newObject:teleport(obj.cell,obj.position,obj.rotation)
    end
end
local function turnCellLightsOff(cell)
    for index, value in ipairs(cell:getAll(types.Light)) do
        turnLightOff(value)
        print(value.recordId)
    end
end
return
{
    interfaceName = "MorroVault_Light",
    interface = {
        turnLightOff = turnLightOff,
        turnLightOn = turnLightOn,
        turnCellLightsOff = turnCellLightsOff,
        
    },
    engineHandlers = {
        onSave = function ()
            return {
                createdLightOffObjects = createdLightOffObjects,
                createdLightOffRecords = createdLightOffRecords,
                createdLightOnObjects = createdLightOnObjects,
            }
        end,
        onLoad = function (data)
            if data then
                createdLightOffObjects = data.createdLightOffObjects
                createdLightOffRecords = data.createdLightOffRecords
                createdLightOnObjects = data.createdLightOnObjects
            end
        end
    },
    eventHandlers = {
    }
}
