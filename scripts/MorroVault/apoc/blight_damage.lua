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

local aux_core = require("scripts.MorroVault.aux_core")
if not core.contentFiles.has("evilsky.ESP") then
    return {}
end

local DagothLoc = util.vector3(20880, 68992, 10880)
local maxDist2 = 234281
local maxDist1 = 33052
local maxDamage1 = 40
local maxDamage2 = 20
local function getDamageToDeal()
    if not self.cell.isExterior then
        return 0
    else
        local distance = (DagothLoc - self.position):length()
        local damage = 0
        if distance < maxDist1 then
            damage  =  maxDamage1 * (1 - (distance / maxDist1))
        elseif distance < maxDist2 then
           damage =  maxDamage2 * (1 - (distance / maxDist2))
        end
        damage = damage - aux_core.getArmorRating(self)
        return math.min(damage,0)
    end
end
local function applyDamage(damage)
    local useMagic = false
    if useMagic then
        local activeEffects = types.Actor.activeEffects(self)
        if damage <= 0 then
            if activeEffects:getEffect(core.magic.EFFECT_TYPE.DamageHealth).magnitude > 0 then
                activeEffects:remove(core.magic.EFFECT_TYPE.DamageHealth)
            end
        else
            if activeEffects:getEffect(core.magic.EFFECT_TYPE.DamageHealth).magnitude ~= damage then
                activeEffects:set(damage,core.magic.EFFECT_TYPE.DamageHealth)
    
            end
        end
    elseif damage > 0 then
        types.Actor.stats.dynamic.health(self).current = types.Actor.stats.dynamic.health(self).current - damage
    end
end
local timePassed = 0
local function onUpdate(dt)
    timePassed = timePassed + dt
    if timePassed > 1 then
        local damage = getDamageToDeal()
        applyDamage(damage)
        timePassed = 0
    end
  
end



return {
    engineHandlers = {
        onUpdate = onUpdate
    }
}