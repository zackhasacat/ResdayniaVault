

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

return {

    interfaceName = "MorroVault_Schedule",
    interface = {
        formatCurrentTime = formatCurrentTime,
        getCurrentTime = getCurrentTime,
      autoClose = autoClose,
    },
}