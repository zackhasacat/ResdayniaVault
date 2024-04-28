

local world = require("openmw.world")
local I = require("openmw.interfaces")
local util = require("openmw.util")
local core = require("openmw.core")
local types = require("openmw.types")
local async = require("openmw.async")
local anim = require('openmw.animation')
local calendar = require('openmw_aux.calendar')
local time = require('openmw_aux.time')

local function getCurrentTime()
    return core.getGameTime() + (time.hour * 12)
end
local function formatCurrentTime(format)
    if not format then
        format = "%X" end
    return calendar.formatGameTime(format, getCurrentTime())
end
local timeBlocks = {
    night = 0,
    morning = 1,
    day = 2,
    evening = 3
}

local function hourToTimeBlock(hour)
    if hour < 6 or hour > 21 then
        return timeBlocks.night
    elseif hour < 12 then
        return timeBlocks.morning
    elseif hour < 18 then
        return timeBlocks.day
    else
        return timeBlocks.evening
    end
end
I.Activation.addHandlerForType(types.NPC, function(npc, actor)
    if actor.type ~= types.Player then
        return
    end
    local script = world.mwscript.getLocalScript(npc,actor)
    if not script then
        return
    end
    local var = script.variables
    if var.zonehour then
        local hourNum = tonumber(I.MorroVault_Schedule.formatCurrentTime("%H"))
        var.zonehour = tonumber(I.MorroVault_Schedule.formatCurrentTime("%H"))
        var.daysection = hourToTimeBlock(hourNum)
    end
end)
return {

    interfaceName = "MorroVault_Schedule",
    interface = {
        formatCurrentTime = formatCurrentTime,
        getCurrentTime = getCurrentTime,
    },
}