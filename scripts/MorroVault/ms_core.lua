local marascript = {}

function marascript.addEvent(ms, event, func)
    if not ms.events then
        ms.events = {}
    end
    ms.events[event] = func
end

function marascript.getData(ms, id)
    if not ms.initDone then
        error("GetData may not be used in the main body of the script")
    end
    if tes3 then
        if not tes3.player then
            return
        end
        if not tes3.player.data["Marascript_" .. ms.modName] then
            tes3.player.data["Marascript_" .. ms.modName] = {}
        end
        return tes3.player.data["Marascript_" .. ms.modName][id]
    end
    if not ms.MS_Data then
        ms.MS_Data = {}
    end
    return ms.MS_Data[id]
end

function marascript.setData(ms, id, data)
    if tes3 then
        if not tes3.player then
            return
        end
        if not tes3.player.data["Marascript_" .. ms.modName] then
            tes3.player.data["Marascript_" .. ms.modName] = {}
        end
        tes3.player.data["Marascript_" .. ms.modName][id] = data
        return
    end
    if not ms.MS_Data then
        ms.MS_Data = {}
    end
    ms.MS_Data[id] = data
end

function marascript.returnTable(ms)
    ms.initDone = true
    if tes3 then
        return 
    end
    if not ms.modName then
        error("modName not set")
    end
    local engineHandlers = {}
    engineHandlers.onSave = function()
        return {
            MS_Data = ms.MS_Data,
        }
    end
    engineHandlers.onLoad = function(data)
        ms.MS_Data = data.MS_Data
    end
    if ms.events then
        for key, value in pairs(ms.events) do
            engineHandlers[key] = value
        end
    end
    local ev = {
        interfaceName = "MS_" .. ms.modName,
        engineHandlers = engineHandlers,
        interface = {
            getData = function(id)
                return ms:getData(id)
            end,
            setData = function(id, data)
                ms:setData(id, data)
            end,
        }
    }
    return ev
end

function marascript.init(modName)
    local copy = {}
    for key, value in pairs(marascript) do
        copy[key] = value
    end
    copy.modName = modName
    return copy
end

return marascript
