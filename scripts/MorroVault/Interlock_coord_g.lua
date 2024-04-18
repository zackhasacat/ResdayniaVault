local world = require("openmw.world")
local I = require("openmw.interfaces")
local util = require("openmw.util")
local core = require("openmw.core")
local types = require("openmw.types")
local async = require("openmw.async")
local anim = require('openmw.animation')


local function setObjectState(id, state)
    local cell = world.players[1].cell
    local state1 = false
    local state2 = false
    for index, value in ipairs(cell:getAll()) do
        if value.recordId == id then
            value.enabled = state
        end
    end
end
local function setSafeState(safe)
    local delay = 0
    if safe then
        delay = 5
    end
    async:newUnsavableSimulationTimer(delay, function()
    for index, value in ipairs(world.players[1].cell:getAll(types.NPC)) do
        if types.NPC.record(value).class == "guard" then
            value:sendEvent("setSafeState", safe)
        end
    end
end)
    setObjectState("zhac_vault_entrylight_2_g", safe)
    setObjectState("zhac_vault_entrylight_2_r", not safe)
    setObjectState("zhac_vault_entrylight_1_g", safe)
    setObjectState("zhac_vault_entrylight_1_r", not safe)
    setObjectState("zhac_vault_entrykey2_act", not safe)
    setObjectState("zhac_vault_entrykey1_act", not safe)
end
return
{
    interfaceName = "MorroVault_Interlock",
    interface = {
        setSafeState = setSafeState,
    },
    engineHandlers = {
    },
    eventHandlers = {
    }
}
