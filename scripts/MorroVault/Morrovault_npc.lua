-- OpenMW Lua Script: Terminal Interface
local core = require("openmw.core")
local async = require("openmw.async")
local util = require("openmw.util")
local self = require("openmw.self")
local vfs = require('openmw.vfs')
local types = require('openmw.types')
local I = require("openmw.interfaces")
local anim = require('openmw.animation')
local nearby = require('openmw.nearby')
--util.vector3(11159.32421875, 4615.380859375, 11393)
local faceAngle
local nextDest
local speakWhenDone
local waitForPlayerLeft
local waitForPlayerRight
local checkInWhenDone
local function makeAgressive()
    types.Actor.stats.ai.fight(self).base = 100
end
return {
    engineHandlers = {
        onUpdate = onUpdate,
    },
    eventHandlers = {
        makeAgressive = makeAgressive,
        exitVaultRight = exitVaultRight,
        exitVaultLeft = exitVaultLeft,
        exitVaultCenter = exitVaultCenter,
        returnToVaultRight = returnToVaultRight,
    }
}
