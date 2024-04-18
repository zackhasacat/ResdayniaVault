local doorObj
local doorOpening = false
local doorClosing = false
local playerIsInVault = false
local checkForExit = false
local openDelay = 2
local openSoundStage = 0
local AITravel = require("ZackHasACat.Vault.AITravel")
require("ZackHasACat.Vault.ItemStorage")
local cutsceneState

local function getObjByID(id, cell)
    cell = cell or tes3.getPlayerCell()
    for obj in cell:iterateReferences() do
        if obj.baseObject.id:lower() == id:lower() then
            return obj
        end
    end
end

local function playSound(id, reference, volume)
    tes3.playSound { sound = id, reference = reference, volume = volume }
end

local function openDoor()
    doorOpening = true
    openSoundStage = 0
    tes3.getReference("zhac_vault_lightblocker1"):disable()
    tes3.getReference("zhac_vault_lightblocker2"):disable()
    if not doorObj then
        doorObj = tes3.getReference("zhac_vault_door") -- Retrieve the door object directly
    end
    playSound("Door Stone Open", doorObj, 1)
    timer.start {
        duration = openDelay,
        callback = function()
            tes3.setGlobal("zhac_doorstate", 1)
            playSound("SothaDoorOpen", doorObj, 1)
        end,
        type = timer.simulate
    }
    playerIsInVault = tes3.player.position.x > 11318
    checkForExit = true
end

local function closeDoor()
    tes3.setGlobal("zhac_doorstate", 0)
    doorClosing = true
    openSoundStage = 0
end
local function finishDoorClose()
    
    tes3.getReference("zhac_vault_lightblocker1"):enable()
    tes3.getReference("zhac_vault_lightblocker2"):enable()
    tes3.playSound({ sound = "AB_Thunderclap0", reference = doorObj, volume = 1 })
    doorClosing = false
end
local function getAnimationTime(obj)
    return tes3.getAnimationTiming({ reference = obj })[1]
end
local function getAnimationTimeOpen(obj)
    local val = tes3.getAnimationTiming({ reference = obj })[1]
    if val then
        return val - 6
    end
end
local function onUpdate()
    -- Ensure the door object is initialized
    if not doorObj then
        doorObj = tes3.getReference("zhac_vault_door") -- Retrieve the door object directly
    end

    -- Handle door closing animation and sound effects
    if doorClosing then
        local timing = getAnimationTime(doorObj)
        if timing and timing > 12 then -- Approximately corresponds to 12 seconds based on the animation length
           
            finishDoorClose()
        elseif timing then
            local currentTime = timing
            if openSoundStage == 0 and currentTime > 7.4 then
                tes3.playSound({ sound = "AB_SteamHammerStrike", reference = doorObj, volume = 1 })
                openSoundStage = 1
            elseif openSoundStage == 1 and currentTime > 8 then
                tes3.playSound({ sound = "AB_SteamHammerStrike", reference = doorObj, volume = 1 })
                openSoundStage = 2
            elseif openSoundStage == 2 and currentTime > 9 then
                tes3.playSound({ sound = "AB_SteamHammerStrike", reference = doorObj, volume = 1 })
                openSoundStage = 3
            end
        end
    end

    -- Handle door opening animation and trigger further events
    if doorOpening then
        local timing = tes3.getAnimationTiming({ reference = doorObj })[1]
        if timing then
            if timing > 6.6 then -- Corresponds to the animation nearing its end
                doorOpening = false
       
            elseif timing then
                if openSoundStage == 0 and timing > 2.1 then
                    tes3.playSound({ sound = "AB_SteamHammerStrike", reference = doorObj, volume = 1 })
                    openSoundStage = 1
                elseif openSoundStage == 1 and timing > 3.4 then
                    tes3.playSound({ sound = "AB_SteamHammerStrike", reference = doorObj, volume = 1 })
                    openSoundStage = 2
                elseif openSoundStage == 2 and timing > 3.9 then
                    tes3.playSound({ sound = "AB_SteamHammerStrike", reference = doorObj, volume = 1 })
                    openSoundStage = 3
                elseif openSoundStage == 3 and timing > 4.6 then
                    tes3.playSound({ sound = "AB_SteamHammerStrike", reference = doorObj, volume = 1 })
                    openSoundStage = 4
                end
            end
        end
    end

    -- Check if the player exits the vault
    if checkForExit then
        local stage = tes3.getGlobal("zhac_vault1_stage")
       -- if stage and stage >= 50 then
            local playerIsInVaultNow = tes3.player.position.x > 11318
            if playerIsInVaultNow ~= playerIsInVault then
                closeDoor()
                checkForExit = false
            end
       -- end
    end
end

local function onActivation(e)
    if e.target.object.id:lower() == "zhac_door_button" or  e.target.object.id:lower() == "ab_furn_shrinemephala_a" then
        if tes3.getGlobal("zhac_doorstate") == 0 then
            openDoor()
        else
            closeDoor()
        end
        return false -- Block the default activation
    end
end

event.register("simulate", onUpdate)
event.register("activate", onActivation)

local function onCellChanged()
    doorObj = nil -- Reset door object on cell change to avoid referencing errors
end
local function referenceActivatedCallback(e)
    if e.reference.object.id:lower() == "zhac_vault_exitmarker" then
        e.reference:delete()
        openDoor()
    end
end
event.register(tes3.event.referenceActivated, referenceActivatedCallback)

event.register("cellChanged", onCellChanged)
