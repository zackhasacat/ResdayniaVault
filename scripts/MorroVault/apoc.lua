local world = require("openmw.world")
local I = require("openmw.interfaces")

local util = require("openmw.util")
local core = require("openmw.core")
local types = require("openmw.types")
local async = require("openmw.async")
local anim = require("openmw.animation")

if not core.contentFiles.has("evilsky.ESP") then
    return {}
end
local processedCells = {}
local processedActors = {}

local function startsWith(inputString, startString)
    return string.sub(inputString, 1, string.len(startString)) == startString
end

local itemBlacklist = { "a_siltstrider",
    "ex_ship_plank"
}
local creatureBlacklist = {
    "ash_ghoul",
    "zhac_vault_skeleton"
}

local function replaceWithActor(npc, newId, transferInv)
    table.insert(creatureBlacklist, newId)
    local newItem = world.createObject(newId)
    newItem:teleport(npc.cell, npc.position, npc.rotation)
    if transferInv then
        for _, value in ipairs(types.Actor.inventory(npc):getAll()) do
            value:moveInto(newItem)
        end
    end
    npc:remove()
end
math.randomseed(os.time())
local function isInVault(obj)
    return startsWith(obj.cell.name, "Resdaynia Sanctuary")
end
local function makeCellApoc(cell)
    for index, value in ipairs(cell:getAll()) do
        if value.owner.recordId then
            value.owner.recordId = nil
        end
        if value.owner.factionId then
            value.owner.factionId = nil
        end

        if value.type.baseType == types.Item then
            local check = math.random(1, 100)
            if check < 50 then
                value:remove()
            end
        end
        if value.count > 0 then
            
        local record = value.type.records[value.recordId]
        if record.mwscript and record.mwscript:lower() == "outsidebanner" then
            value:remove()
        elseif record.mwscript and record.mwscript:lower() == "signrotate" then
            value:remove()
        end
        end
    end
end
local function onActorActive(act)
    if isInVault(act) or processedActors[act.id] then
        return
    end
    print(act.recordId)
    local randomNumber = math.random(0, 100)
    processedActors[act.id] = true
    if act.type == types.Creature then
        for index, value in ipairs(creatureBlacklist) do
            if value == act.recordId then
                return
            end
        end
    end
    if not act.cell.isExterior then
        if not processedCells[act.cell.name] then
            makeCellApoc(act.cell)
            processedCells[act.cell.name] = true
        end
    else
        if not processedCells[tostring(act.cell.gridX) .. "-" .. tostring(act.cell.gridY)] then
            makeCellApoc(act.cell)
            processedCells[tostring(act.cell.gridX) .. "-" .. tostring(act.cell.gridY)] = true
        end
    end
    if act.type == types.NPC then
        local race = types.NPC.record(act).race
        if race:lower() == "dark elf" and randomNumber < 30 then
            for index, value in ipairs(types.Actor.inventory(act):getAll()) do
                value:remove()
            end
            local club = world.createObject("iron club")
            club:moveInto(act)
            act:sendEvent("makeAgressive")
            return
        elseif randomNumber < 20 then
            replaceWithActor(act, "ash_ghoul", true)
        elseif randomNumber < 30 then
            local newObj = world.createObject("Sound_Haunted00")
            newObj:teleport(act.cell, act.position)
            act:remove()
        else
            if act.cell.isExterior then
                act:remove()
            else
                replaceWithActor(act, "zhac_vault_skeleton", true)
            end
        end
        return
    end
    if not isInVault(act) then
        act:remove()
    end
end
local function onObjectActive(act)
    if act.type == types.Light then
        if not isInVault(act) then
            I.MorroVault_Light.turnLightOff(act)
            --   act:remove()
            --   act.enabled = false
            return
        end
    end
    for index, value in ipairs(itemBlacklist) do
        if value == act.recordId then
            act:remove()
            act.enabled = false
        end
    end
end
return
{
    engineHandlers = {
        onObjectActive = onObjectActive,
        onActorActive = onActorActive,
    },
    eventHandlers = {
    }
}
