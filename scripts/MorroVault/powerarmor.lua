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
local function calculateHeightForSecondActor(actor1,actor2)
    local race1Id = types.NPC.record(actor1).race
    local race2Id = types.NPC.record(actor2).race
    local race1 = types.NPC.races.records[race1Id]
    local race2 = types.NPC.races.records[race2Id]

    local actor1male = types.NPC.record(actor1).isMale
    local actor2male= types.NPC.record(actor2).isMale

    local actor1RaceHeight
    local actor2RaceHeight
    if actor1male then
     --   actor1RaceHeight 
    end

end

return
{
    interfaceName = "PArmor",
    interface = {
        calculateHeightForSecondActor = calculateHeightForSecondActor,
    }
}