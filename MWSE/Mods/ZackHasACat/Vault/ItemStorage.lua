
local storedEquip = {}
local storedEquip2 = {}

local function getStorageContainer(id)
    for ref in tes3.getPlayerCell():iterateReferences(tes3.objectType.container) do
        if ref.baseObject.id:lower() == id:lower() then
            return ref
        end
    end
end

local function equipmentToStored(actor)
    local eq = {}
    for stack in tes3.iterate(actor.object.equipment) do
        if stack.object then
            eq[stack.object.id:lower()] = true
        end
    end
    return eq
end

local function storeEquipment(player, storageId, storedList)
    local container =tes3.getReference(storageId) 
    if container then
   tes3.transferInventory({from=player,to=container,playSound=false,limitCapacity=false,})
    end
    return storedList
end

local function retrieveEquipment(player, storageId, storedList)
    local container =tes3.getReference(storageId) 
    if container then
     
   tes3.transferInventory({from=container,to=tes3.player,playSound=false,limitCapacity=false,})
    end
end

local function onReferenceActivated(e)
    local targetId = e.reference.baseObject.id:lower()
    local player = tes3.player

    if targetId == "zhac_vault_itemstoremarker1" then
        tes3.setGlobal("zhac_vault_invstate", 1)
        storedEquip = storeEquipment(player, "zhac_bchest_outside", storedEquip)
        tes3.messageBox("Equipment stored.")
       e.reference:delete()
    elseif targetId == "zhac_vault_itemstoremarker2" then
        tes3.setGlobal("zhac_vault_invstate", 0)
        retrieveEquipment(player, "zhac_bchest_outside", storedEquip)
        storedEquip = {}
        tes3.messageBox("Equipment retrieved.")
        e.reference:delete()
    elseif targetId == "zhac_vault_itemstoremarker3" then
        tes3.setGlobal("zhac_vault_invstate2", 1)
        storedEquip2 = storeEquipment(player, "zhac_bchest_inside", storedEquip2)
        tes3.messageBox("Equipment stored.")
        e.reference:delete()
    elseif targetId == "zhac_vault_itemstoremarker4" then
        tes3.setGlobal("zhac_vault_invstate2", 0)
        retrieveEquipment(player, "zhac_bchest_inside", storedEquip2)
        storedEquip2 = {}
        tes3.messageBox("Equipment retrieved.")
        e.reference:delete()
    end
end

event.register("referenceActivated", onReferenceActivated, { filter = tes3.player })
