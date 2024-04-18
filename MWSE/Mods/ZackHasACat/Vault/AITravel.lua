
-- Helper function to create a travel AI package for an NPC
local function startTravelPackage(npc, destination)
    local travelPackage = tes3.aiPackage.travel
    tes3.positionCell({
        reference = npc,
        cell = npc.cell,
        position = destination,
        orientation = npc.orientation
    })
end

-- Handle the movement and facing of NPCs
local function travelAndFace(npc, data)
    npc.data.faceAngle = data.angle
    npc.data.nextDest = data.nextDest
    if data.destPosition then
        startTravelPackage(npc, data.destPosition)
    end
end

local function executeAI(npc, dest1, dest2)
    npc.mobile:enableAI(true)
    travelAndFace(npc, { destPosition = dest1, nextDest = dest2 })
end

local function returnToVaultLeft(npc)
    executeAI(npc, tes3vector3.new(11606.14453125, 4165.1533203125, 11393),
                   tes3vector3.new(11621.890625, 4243.31640625, 11393))
end

local function returnToVaultRight(npc)
    executeAI(npc, tes3vector3.new(11650.5810546875, 4684.20849609375, 11393),
                   tes3vector3.new(11650.4609375, 4638.61376953125, 11393))
end

local function exitVaultLeft(npc)
    npc.data.waitForPlayerLeft = true
    executeAI(npc, tes3vector3.new(11154.443359375, 4205.99267578125, 11393),
                   tes3vector3.new(10905.736328125, 4205.05810546875, 11393))
end

local function exitVaultRight(npc)
    npc.data.waitForPlayerRight = true
    executeAI(npc, tes3vector3.new(11154.443359375, 4601.99267578125, 11393),
                   tes3vector3.new(10905.736328125, 4592.05810546875, 11393))
end

local function exitVaultCenter(npc)
    startTravelPackage(npc, tes3vector3.new(10757.669921875, 4378.958984375, 11393))
    npc.data.speakWhenDone = true
end

-- Handle NPC updates, movements, and interactions
local function onUpdate(e)
    local npc = e.reference
    if not npc or not npc.mobile then return end

    local player = tes3.player
    if npc.data.waitForPlayerLeft and player.position.x > 11318 then
        returnToVaultLeft(npc)
        npc.data.waitForPlayerLeft = false
    end

    if npc.data.waitForPlayerRight and player.position.x > 11318 then
        returnToVaultRight(npc)
        npc.data.waitForPlayerRight = false
    end

    if npc.data.faceAngle and npc.rotation.z ~= npc.data.faceAngle then
        -- Logic to rotate NPC to face a specific angle
        -- More complex rotation logic may be needed here
        npc.data.faceAngle = nil
    end

    if npc.data.nextDest and not npc.mobile.inCombat then
        startTravelPackage(npc, npc.data.nextDest)
        npc.data.nextDest = nil
    end

    if npc.data.speakWhenDone and not npc.mobile.inCombat then
        timer.start({
            duration = 5,
            callback = function()
                npc:startDialogue()
            end
        })
        npc.data.speakWhenDone = false
    end
end

-- Register the onUpdate function to the mobileActivated event
event.register("mobileActivated", onUpdate)

-- Script initialization to store relevant functions
local script = {
    onUpdate = onUpdate,
    exitVaultRight = exitVaultRight,
    exitVaultLeft = exitVaultLeft,
    exitVaultCenter = exitVaultCenter,
    returnToVaultRight = returnToVaultRight,
    returnToVaultLeft = returnToVaultLeft
}
return script