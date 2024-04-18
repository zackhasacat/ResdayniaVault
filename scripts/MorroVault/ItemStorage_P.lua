-- OpenMW Lua Script: Terminal Interface
local core = require("openmw.core")
local input = require("openmw.input")
local ui = require("openmw.ui")
local async = require("openmw.async")
local util = require("openmw.util")
local self = require("openmw.self")
local vfs = require('openmw.vfs')
local types = require('openmw.types')
local storage = require('openmw.storage')
local I = require("openmw.interfaces")
local anim = require('openmw.animation')
local nearby = require('openmw.nearby')
local debug = require('openmw.debug')
local camera = require('openmw.camera')


return {

    eventHandlers = {
        setEquipment = function(list)
            async:newUnsavableSimulationTimer(1, function()
            local newEq = {}
            for key, value in pairs(list) do
                for index, xvalue in ipairs(types.Actor.inventory(self):getAll()) do
                    if xvalue.recordId == value then
                        newEq[key] = xvalue
                    end
                end
            end
            types.Actor.setEquipment(self, newEq)

        end)
        end,
        startCutscene = function ()
            types.Player.setControlSwitch(self, types.Player.CONTROL_SWITCH.Controls, false)
        end
    },
    engineHandlers = {
        onConsoleCommand  = function (m,command)
            if command:lower() == "gotovault" then
                core.sendGlobalEvent("goToVault")
            end
        end
    }
}
