

local self = require('openmw.self')


local core = require('openmw.core')

local nearby = require('openmw.nearby')
if self.recordId ~= "zhac_vault_door" then
    return {}
end
local firstApproach = false
local anim = require('openmw.animation')
anim.setLoopingEnabled(self, "idle2", false)
local cutsceneState = 0

local function doorOpen()
    anim.clearAnimationQueue(self, true)
    anim.playQueued(self, "death2",{})

end
local function doorClose()
    anim.clearAnimationQueue(self, true)
    anim.playQueued(self,"Death1",{})
   -- anim.playQueued(self, "idle3")
end
local function onUpdate()
    if self.recordId ~= "zhac_vault_door" then
        return 
    end
    local player = nearby.players[1]
    if not player then return end
    local dist = (self.position - player.position):length()
    --print(dist)
    if dist < 800 and cutsceneState == 1 then
        cutsceneState = 2 
        core.sendGlobalEvent("StartCutscene1")
    end
    if dist < 2000 and not firstApproach then
        firstApproach = true
        core.sendGlobalEvent("firstApproach")
    end
end
local function setCutsceneState(sta)
    cutsceneState = sta
end
return
{
    eventHandlers = {
        doorClose = doorClose,
        doorOpen = doorOpen,
        setCutsceneState = setCutsceneState,
    },
    engineHandlers = {
        onUpdate = onUpdate,
    }
}