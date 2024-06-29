local ms_core = require("scripts.MorroVault.ms_core")
local types = require("openmw.types")
ms_core = ms_core.init("BountyTracker")
local world = require("openmw.world")
local outsideBounty = 0
local vaultBounty = 0
local amInVault = false
local function switchToVault()
    if amInVault then
        return
    end
    outsideBounty = types.Player.getCrimeLevel(world.players[1])
    types.Player.setCrimeLevel(world.players[1],vaultBounty)
    amInVault = true
end
local function exitVault()
    if not amInVault then
        return
    end
    vaultBounty = types.Player.getCrimeLevel(world.players[1])
    types.Player.setCrimeLevel(world.players[1],outsideBounty)
    amInVault = false
end
local function isInVault()
    return amInVault
end

return {
    interfaceName = "MorroVault_Bounty",
    interface = {
        switchToVault = switchToVault,
        exitVault = exitVault,
        isInVault = isInVault,
    },
    engineHandlers = {
        onSave = function ()
            return {
                outsideBounty = outsideBounty,
                vaultBounty = vaultBounty,
                amInVault = amInVault
            }
        end,
        onLoad = function (data)
            if data then
                outsideBounty = data.outsideBounty
                vaultBounty = data.vaultBounty
                amInVault = data.amInVault
            end
        end
    }
}