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
    showPlayerMessage = function (msg)
        ui.showMessage(msg)
    end
    },
    engineHandlers = {

    }
}
