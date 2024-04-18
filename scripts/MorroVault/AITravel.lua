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
local function travelAndFace(data)
    faceAngle = data.angle
    nextDest = data.nextDest
    if data.destPosition then
        self:sendEvent('StartAIPackage', { type = 'Travel', destPosition = data.destPosition })
    end
end
local function exitVaultRight()
    self:enableAI(true)
    waitForPlayerRight = true
    local dest1 = util.vector3(11154.443359375, 4601.99267578125, 11393)

    local dest2 = util.vector3(10905.736328125, 4592.05810546875, 11393)
    travelAndFace({ destPosition = dest1, nextDest = dest2 })
end
local function returnToVaultLeft()
    self:enableAI(true)
    local dest1 = util.vector3(11606.14453125, 4165.1533203125, 11393)

    local dest2 = util.vector3(11621.890625, 4243.31640625, 11393)
    travelAndFace({ destPosition = dest1, nextDest = dest2 })
end
    local function returnToVaultRight()
    self:enableAI(true)
    local dest1 = util.vector3(11650.5810546875, 4684.20849609375, 11393)

    local dest2 = util.vector3(11650.4609375, 4638.61376953125, 11393)
    travelAndFace({ destPosition = dest1, nextDest = dest2 })
end
local function exitVaultLeft()
    self:enableAI(true)
    waitForPlayerLeft = true
    local dest1 = util.vector3(11154.443359375, 4205.99267578125, 11393)

    local dest2 = util.vector3(10905.736328125, 4205.05810546875, 11393)
    travelAndFace({ destPosition = dest1, nextDest = dest2 })
end
local function exitVaultCenter()
    local dest = util.vector3(10757.669921875, 4378.958984375, 11393)
    self:sendEvent('StartAIPackage', { type = 'Travel', destPosition = dest })
    speakWhenDone = true
end
local function onUpdate(dt)
    local mrot = math.deg(self.rotation:getAnglesZYX())
    local integer = (mrot > 0) and math.floor(mrot) or math.ceil(mrot)

    local player = nearby.players[1]
    if not player then return end
    if waitForPlayerLeft and player.position.x > 11318 then
        returnToVaultLeft()
        waitForPlayerLeft = false
        checkInWhenDone = true
    end
    if waitForPlayerRight and player.position.x > 11318 then
        returnToVaultRight()
        waitForPlayerRight = false
        checkInWhenDone = true
    end
    if checkInWhenDone and self.position.x > 11454 then
        core.sendGlobalEvent("checkInWhenDone",self.recordId)
        checkInWhenDone = false
    end

    if faceAngle and (not I.AI.getActivePackage() or I.AI.getActivePackage().type ~= "Travel") then
        -- self:enableAI(false)
        if integer > faceAngle then
            self.controls.yawChange = -0.01
            print("Not", integer, faceAngle)
        elseif integer < faceAngle then
            self.controls.yawChange = 0.01
            print("Not", integer, faceAngle)
        else
            faceAngle = nil
            print("Done", integer, faceAngle)
        end
    end
    if nextDest and not I.AI.getActivePackage() then
        self:sendEvent('StartAIPackage', { type = 'Travel', destPosition = nextDest })
        nextDest = nil
    end
    if speakWhenDone and not I.AI.getActivePackage() then
        async:newUnsavableSimulationTimer(5, function()
            nearby.players[1]:sendEvent('SetUiMode', { mode = 'Dialogue', target = self })
        end)
        speakWhenDone = false
    end
end
local function setSafeState(state)
    async:newUnsavableSimulationTimer(math.random(0.1,3), function()
        if not state then
            self:enableAI(false)
            types.Actor.setStance(self,1)
        else
            self:enableAI(true)
    
        end
            end)

end
return {
    engineHandlers = {
        onUpdate = onUpdate,
    },
    eventHandlers = {
        travelAndFace = travelAndFace,
        exitVaultRight = exitVaultRight,
        exitVaultLeft = exitVaultLeft,
        exitVaultCenter = exitVaultCenter,
        returnToVaultRight = returnToVaultRight,
        setSafeState = setSafeState,
    }
}
