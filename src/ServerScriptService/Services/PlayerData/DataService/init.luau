--!strict

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()


-- TODO
local DataService = {}
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

-- Returns the player's data
function DataService.GetPlayerDataAsync(Player: Player): {[string]: any}
    return DataTemplate
end

-- Returns if the player's data has been loaded
function DataService.DataLoaded(Player: Player): boolean
    return true
end

-- Permanently deletes the player's data
function DataService.DeleteDataAsync(Player: Player): boolean
    return true
end

local function LoadProfile(Player: Player): boolean

end

local function RemoveProfile(Player: Player): boolean

end

return DataService