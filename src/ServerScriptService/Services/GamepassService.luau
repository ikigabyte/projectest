--!strict

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

local MarketplaceService = Scrypt.Services.MarketplaceService
local GamepassService = {}
--[=[
    @class GamepassService
    @server
]=]

--[=[
    @param Player Player
    @param GamepassId number
    @within GamepassService
    @return boolean
    Returns whether the player has a gamepass or not.
]=]
function GamepassService.HasGamepass(Player: Player, GamepassId: number): boolean
    local success, hasGamepass = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(Player.UserId, GamepassId)
    end)

    return success and hasGamepass
end

--[=[
    @param Player Player
    @param GamepassId number
    @within GamepassService
    @return boolean
    Prompts the player to buy a gamepass. Returns whether the prompt was successful or not.
]=]
function GamepassService.PromptGamePassPurchase(Player: Player, GamepassId: number): boolean
    local success, result = pcall(function()
        return MarketplaceService:PromptGamePassPurchase(Player, GamepassId)
    end)

    return success
end

--[=[
    @param GamepassId number
    @within GamepassService
    @return any
    Returns a gamepass product info table.
]=]
function GamepassService.GetGamepassInfo(GamepassId: number): any
    -- Get the gamepass info
    local success, info = pcall(function()
        return MarketplaceService:GetProductInfo(GamepassId)
    end)

    assert(success, "Failed to get gamepass info")
    return info
end

--[=[
    @param Player Player
    @param GamepassId number
    @within GamepassService
    @unreleased
    Adds a gamepass to the player's data.
]=]
function GamepassService.AddPassToData(Player: Player, GamepassId: number)
    -- TODO once we add a proper data system
end

--[=[
    @param Player Player
    @param GamepassId number
    @within GamepassService
    @unreleased
    Removes a gamepass from the player's data.
]=]
function GamepassService.RemovePassFromData(Player: Player, GamepassId: number)
    -- TODO once we add a proper data system
end

return GamepassService