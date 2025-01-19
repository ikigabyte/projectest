--!strict

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()


-- TODO
local DataService = {}
--[=[
    @class DataService
    @server
]=]

local DataTemplate = require(script.Template)
-- local ProfileService = require(script.ProfileService)

-- Constants
local DEBUG = true
local DATA_VERSION = 1
local DATA_STORE_KEY = `DEV_DATA_{tostring(DATA_VERSION)}`

local Profiles = {}
-- local GameProfileStore = ProfileService.GetProfileStore(DATA_STORE_KEY, DataTemplate)

if Scrypt.Services.RunService:IsStudio() == true and DEBUG then
	-- GameProfileStore = GameProfileStore.Mock
end

--[=[
    @param Player Player
    @return {[string]: any}
    @within DataService
    @unreleased
    Returns the player's data.
]=]
function DataService.GetPlayerDataAsync(Player: Player): {[string]: any}
    return DataTemplate
end

--[=[
    @param Player Player
    @return boolean
    @within DataService
    @unreleased
    Returns if the player's data has been loaded.
]=]
function DataService.DataLoaded(Player: Player): boolean
    return true
end

--[=[
    @param Player Player
    @return boolean
    @within DataService
    @unreleased
    Permanently deletes the player's data.
]=]
function DataService.DeleteDataAsync(Player: Player): boolean
    return true
end

local function LoadProfile(Player: Player): boolean

end

local function RemoveProfile(Player: Player): boolean

end

return DataService