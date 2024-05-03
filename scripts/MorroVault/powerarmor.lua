--[[custom race, scaled up 1.5xish
large weight



--]]
local world = require("openmw.world")
local I = require("openmw.interfaces")
local util = require("openmw.util")
local core = require("openmw.core")
local types = require("openmw.types")
local async = require("openmw.async")
local anim = require('openmw.animation')

local playerHeight
local playerEquip
local function calculateHeightForSecondActor(actor1, actor2)
    -- Retrieve race IDs and records
    local race1Id = types.NPC.record(actor1).race
    local race2Id = types.NPC.record(actor2).race
    local race1 = types.NPC.races.records[race1Id]
    local race2 = types.NPC.races.records[race2Id]

    -- Determine gender of actors
    local actor1male = types.NPC.record(actor1).isMale
    local actor2male = types.NPC.record(actor2).isMale

    -- Determine race-based height based on gender
    local actor1RaceHeight = actor1male and race1.height.male or race1.height.female
    local actor2RaceHeight = actor2male and race2.height.male or race2.height.female

    -- Retrieve current scales of actors
    local actor1scaledHeight = actor1.scale
    local actor2scaledHeight = actor2.scale

    -- Calculate the effective height of the first actor
    local actor1EffectiveHeight = actor1RaceHeight * actor1scaledHeight

    -- Calculate the new scale for the second actor to match the first actor's height
    local newScaleForActor2 = actor1EffectiveHeight / actor2RaceHeight

    -- Return the new scale for the second actor
    return newScaleForActor2
end
local tempItems = {}
local function equipPowerArmor(obj, player)
    playerHeight = player.scale
    playerEquip = types.Actor.getEquipment(player)
    player:setScale(calculateHeightForSecondActor(obj, world.players[1]))
    local equip = types.Actor.getEquipment(obj)
    local eqIDs = {}
    for key, value in pairs(equip) do
        table.insert(eqIDs, value.recordId)
    end
    for index, value in ipairs(types.Actor.inventory(obj):getAll()) do
        local newItem = world.createObject(value.recordId)
        newItem:moveInto(player)
        table.insert(tempItems, newItem.id)
    end
    player:sendEvent("setEquipment_PA", eqIDs)
    player:teleport(obj.cell, obj.position, obj.rotation)
    obj:teleport("ToddTest", util.vector3(0, 0, 0))
end
I.Activation.addHandlerForType(types.NPC, function(obj, actor)
    if obj.recordId == "zhac_powerarmor3" then
        equipPowerArmor(obj, actor)
        return false
    end
end)
local function exitPowerArmor(player)
    player:setScale(playerHeight)
    local obj
    for index, value in ipairs(world.getCellByName("ToddTest"):getAll(types.NPC)) do
        if value.recordId == "zhac_powerarmor3" then
            obj = value
            value:teleport(player.cell, player.position, player.rotation)
            break
        end
    end
    for index, value in ipairs(tempItems) do
        for index, value in ipairs(types.Actor.inventory(player):getAll()) do
            if value.id == tempItems[index] then
                value:remove()
            end
        end
    end
    player:sendEvent("setEquipment_PA", playerEquip)
end
return
{
    interfaceName = "PArmor",
    interface = {
        calculateHeightForSecondActor = calculateHeightForSecondActor,
    },
    eventHandlers = {
        exitPowerArmor = exitPowerArmor,
    }
}
