local world = require("openmw.world")
local I = require("openmw.interfaces")
local util = require("openmw.util")
local core = require("openmw.core")
local types = require("openmw.types")
local async = require("openmw.async")
local anim = require('openmw.animation')
local doorClosing = false

local doorOpening = false

local playerIsInVault = false
local checkForExit = false
local cutsceneState = 0
local openDelay = 2
local closeDelay = 5
local openSoundStage = 0

local playerEnteringVault = false
local playerExitingVault = false
local doorObj
local doorBlockerObj
local function getObjByID(id, cell)
    if not cell then
        cell = world.players[1].cell
    end
    for index, value in ipairs(cell:getAll()) do
        if value.recordId == id then
            return value
        end
    end
end
local function getSafeToUnlock(cell)
    if not cell then
        cell = world.players[1].cell
    end
    local state1 = false
    local state2 = false
    for index, value in ipairs(cell:getAll()) do
        if value.enabled then
            if value.recordId == "zhac_vault_entrylight_2_r"  then
                state2 = true
             end
             if value.recordId == "zhac_vault_entrylight_1_r"  then
                state1 = true
             end
        end
        
    end
    return state1 and state2
end
local function setLightBlockersEnabled(state,cell)
    if not cell then
        cell = world.players[1].cell
    end
    for index, value in ipairs(cell:getAll()) do
        if value.recordId == "zhac_vault_lightblocker1" or value.recordId == "zhac_vault_lightblocker2" or value.recordId == "zhac_vault_sound_crys" then
           value.enabled= state
        end
    end
end
local function openDoor()
    if doorOpening then
        return
    end
    doorOpening = true
    
    if not getSafeToUnlock() then
        I.MorroVault_Interlock.setSafeState(false)
        
    end
    setLightBlockersEnabled(false)
    I.TeleportBlocker.setDoorOpen(true)
    core.sound.playSound3d("SothaDoorOpen", doorObj, { volume = 3 })
    world.mwscript.getGlobalVariables(world.players[1]).zhac_vault_doorsafe = 0
    
    async:newUnsavableSimulationTimer(openDelay, function()
        world.mwscript.getGlobalVariables(world.players[1]).zhac_doorstate = 1
        async:newUnsavableSimulationTimer(0.5, function()
            core.sound.playSound3d("Door Stone Open", doorObj, { volume = 5 })
        end
        )
    end
    )
    playerIsInVault = world.players[1].position.x > 11318
    if playerIsInVault then
        playerExitingVault = true
        playerEnteringVault = false
    else
        playerExitingVault = false
        playerEnteringVault = true

    end
    checkForExit = true
    openSoundStage = 0
end
local function closeDoor()
    if doorClosing then
        return
    end
    local completion = anim.getCurrentTime(doorObj, "death1")
    if completion and completion > 12 then--already closed
        return

    end
    if  getSafeToUnlock() then
        I.MorroVault_Interlock.setSafeState(true)
        
    end
    world.mwscript.getGlobalVariables(world.players[1]).zhac_vault_doormagic = 1
    world.mwscript.getGlobalVariables(world.players[1]).zhac_doorstate = 0
    doorClosing = true
    openSoundStage = 0
end
local function finishDoorClose()
    core.sound.playSound3d("AB_Thunderclap0", doorObj, { volume = 3 })
    world.mwscript.getGlobalVariables(world.players[1]).zhac_vault_doormagic = 0
    doorClosing = false
    I.TeleportBlocker.setDoorOpen(false)
    
    setLightBlockersEnabled(true)
    world.mwscript.getGlobalVariables(world.players[1]).zhac_vault_doorsafe = 1
end
local function autoClose()
    async:newUnsavableSimulationTimer(closeDelay, function()
  
closeDoor()
    end)
end
local secsPassed = 0
local function onUpdate(dt)
    if not doorObj then
        for index, value in ipairs(world.players[1].cell:getAll(types.Activator)) do
            if value.recordId == "zhac_vault_door" then
                doorObj = value
            end
        end
    end
    if doorClosing then
        local completion = anim.getCurrentTime(doorObj, "death1")
        if completion and completion > 12 then
            finishDoorClose()
            
        elseif completion then
            if openSoundStage == 0 and completion > 7.4 then
                core.sound.playSound3d("AB_SteamHammerStrike", doorObj, { volume = 5 })
                openSoundStage = 1
            elseif openSoundStage == 1 and completion > 8 then
                core.sound.playSound3d("AB_SteamHammerStrike", doorObj, { volume = 5 })
                openSoundStage = 2
            elseif openSoundStage == 2 and completion > 9 then
                core.sound.playSound3d("AB_SteamHammerStrike", doorObj, { volume = 5 })
                openSoundStage = 3
            end
        end
    end
    if doorOpening then
        local completion = anim.getCurrentTime(doorObj, "death2")
        if completion then
            if completion > 6.6 then
                doorOpening = false
                world.mwscript.getGlobalVariables(world.players[1]).zhac_vault_doormagic = 0

                if types.Player.quests(world.players[1]).zhac_vault1.stage < 41 then
                    if cutsceneState == 1 then
                        cutsceneState = 2
                        local center, right, left = getObjByID("zhac_mvault_rguard_c"), getObjByID("zhac_mvault_lguard"),
                            getObjByID("zhac_mvault_rguard")
                        center:sendEvent("exitVaultCenter")
                        async:newUnsavableSimulationTimer(2, function()
                            left:sendEvent("exitVaultLeft")
                            right:sendEvent("exitVaultRight")
                        end)
                    end
                end
            else
                if openSoundStage == 0 and completion > 2.1 then
                    core.sound.playSound3d("AB_SteamHammerStrike", doorObj, { volume = 5 })
                    openSoundStage = 1
                elseif openSoundStage == 1 and completion > 3.4 then
                    core.sound.playSound3d("AB_SteamHammerStrike", doorObj, { volume = 5 })
                    openSoundStage = 2
                elseif openSoundStage == 2 and completion > 3.9 then
                    core.sound.playSound3d("AB_SteamHammerStrike", doorObj, { volume = 5 })
                    openSoundStage = 3
                elseif openSoundStage == 3 and completion > 4.6 then
                    core.sound.playSound3d("AB_SteamHammerStrike", doorObj, { volume = 5 })
                    openSoundStage = 4
                end
            end
        end
    end
    if checkForExit then
       -- if types.Player.quests(world.players[1]).zhac_vault1.stage >= 50 then
            local playerIsInVaultNow = world.players[1].position.x > 11318
            if playerIsInVaultNow ~= playerIsInVault then
                autoClose()
                checkForExit = false
            end
      --  end
    end
end
--zhac_carryingitems
I.Activation.addHandlerForType(types.Activator, function(obj, actor)

    if obj.recordId == "zhac_door_button" then--or obj.recordId == "ab_furn_shrinemephala_a" then
        local itemCount = types.Actor.inventory(actor):countOf("zhac_vault_doorKey")
        if itemCount < 1 then
            if actor.type == types.Player then
                actor:sendEvent("showPlayerMessage","You do not have the vault control index required to open the door.")
            end
            return
        end
        if world.mwscript.getGlobalVariables(actor).zhac_doorstate == 0 then
            openDoor()
        else
            closeDoor()
        end
        return false
    end
end)
I.Activation.addHandlerForType(types.NPC, function(obj, actor)
    local playerHasItems = false
    for index, value in ipairs(types.Actor.inventory(actor):getAll()) do
        playerHasItems = true
    end
    if playerHasItems then
        world.mwscript.getGlobalVariables(actor).zhac_carryingitems = 1
    else
        world.mwscript.getGlobalVariables(actor).zhac_carryingitems = 0
    end
end)
local function goToVault()
    world.players[1]:teleport("Resdaynia Sanctuary, Entrance",
        util.vector3(8861.6123046875, 4152.15234375, 11424.8330078125))
end
local function StartCutscene1() --make the NPCs come out
    if types.Player.quests(world.players[1]).zhac_vault1.stage < 41 then
        openDoor()
        cutsceneState = 1
        world.players[1]:sendEvent("startCutscene")
        async:newUnsavableSimulationTimer(openDelay, function()

        end)
    end
end
local function firstApproach()
    if types.Player.quests(world.players[1]).zhac_vault1.stage > 0 and  types.Player.quests(world.players[1]).zhac_vault1.stage < 20 then
        types.Player.quests(world.players[1]).zhac_vault1:addJournalEntry(20)
    end
end
local function onPlayerAdded()
   --world.players[1]:teleport("Resdaynia Sanctuary, Entrance", util.vector3(8861.6123046875, 4152.15234375, 11424.8330078125))
end
local checkinCOunt = 0
local function checkInWhenDone(id)
    checkinCOunt = checkinCOunt + 1
    if checkinCOunt > 1 then
       closeDoor()
        doorClosing = true
        checkinCOunt = -1
    end
end
local function onItemActive(item)
    if item.recordId == "zhac_vault_exitmarker" then
        item:remove()
        async:newUnsavableSimulationTimer(openDelay, function()
            openDoor()
        end)
    end
end
return
{
    interfaceName = "MorroVault",
    interface = {
      openDoor = openDoor,
      closeDoor = closeDoor,
      autoClose = autoClose,
    },
    engineHandlers = {
        onUpdate = onUpdate,
        onPlayerAdded = onPlayerAdded,
        onItemActive = onItemActive,
    },
    eventHandlers = {
        goToVault = goToVault,
        StartCutscene1 = StartCutscene1,
        firstApproach = firstApproach,
        checkInWhenDone = checkInWhenDone
    }
}
