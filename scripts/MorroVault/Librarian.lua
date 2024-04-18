local _, world = pcall(require, "openmw.world")
local isOpenMW, I = pcall(require, "openmw.interfaces")

local _, util = pcall(require, "openmw.util")
local _, core = pcall(require, "openmw.core")
local _, types = pcall(require, "openmw.types")
local _, async = pcall(require, "openmw.async")
local anim = require('openmw.animation')
local libraryCell = "Resdaynia Sanctuary, Library"

local libraryData

local function buildLibraryData()
    local bookList = world.getCellByName(libraryCell):getAll(types.Book)
    libraryData = {}
    for index, value in ipairs(bookList) do
        libraryData[value.id] = { position = value.position, rotation = value.rotation, recordId = value.recordId, checkOut = false }
    end
    print("done")
end
local function updateLibraryData()
    if not libraryData then return end
    local bookList = world.getCellByName(libraryCell):getAll(types.Book)
    for key, bookData in pairs(libraryData) do
        local myBook
        for index, book in ipairs(bookList) do
            if key == book.id then
                myBook = book
            end
        end
        if not myBook or myBook.position ~= bookData.position then
            libraryData[key].checkOut = true
        else
            libraryData[key].checkOut = false
        end
    end
end
local function returnPlayerBooks()
    updateLibraryData()
    if not libraryData then return end
    local bookList = world.getCellByName(libraryCell):getAll(types.Book)
    for key, bookData in pairs(libraryData) do
        if bookData.checkOut then
            local playerItem = types.Actor.inventory(world.players[1]):find(bookData.recordId)
            if playerItem then
                local message = core.getGMST("sNotifyMessage62")
                message = string.format(message,playerItem.type.record(playerItem).name)
                world.players[1]:sendEvent("showPlayerMessage",message)
                playerItem:split(1):teleport(libraryCell,bookData.position,bookData.rotation)
                libraryData[key].checkOut = false
            end
        end
    end
end
return
{
    interfaceName = "Librarian",
    interface = {
        getLibraryData = function()
            return libraryData
        end
    },
    engineHandlers = {
        onSave = function()
            return { libraryData = libraryData }
        end,
        onLoad = function(data)
            libraryData = data.libraryData
        end,
        onActorActive = function (actor)
            if actor.recordId == "zhac_vault_librarian_n" and not libraryData then
                buildLibraryData()
            end
        end,
        onItemActive = function (item)
            if item.recordId == "zhac_library_returnmark" then
                item:remove()
                returnPlayerBooks()
            end
        end
    },
    eventHandlers = {
        buildLibraryData = buildLibraryData,
        updateLibraryData = updateLibraryData,
        returnPlayerBooks = returnPlayerBooks,
    }
}
