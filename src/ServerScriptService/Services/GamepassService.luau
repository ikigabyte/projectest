--!strict

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

local MarketplaceService = Scrypt.Services.MarketplaceService
local GamepassService = {}

-- Check if the player has the gamepass
function GamepassService.HasGamepass(Player: Player, GamepassId: number): boolean
    local success, hasGamepass = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(Player.UserId, GamepassId)
    end)

    return success and hasGamepass
end

-- Prommpt the player to buy the gamepass
function GamepassService.PromptGamePassPurchase(Player: Player, GamepassId: number): boolean
    local success, result = pcall(function()
        return MarketplaceService:PromptGamePassPurchase(Player, GamepassId)
    end)

    return success
end

-- Get the gamepass info
function GamepassService.GetGamepassInfo(GamepassId: number): any
    -- Get the gamepass info
    local success, info = pcall(function()
        return MarketplaceService:GetProductInfo(GamepassId)
    end)

    assert(success, "Failed to get gamepass info")
    return info
end

function GamepassService.AddPassToData(Player: Player, GamepassId: number)
    -- TODO once we add a proper data system
end

function GamepassService.RemovePassFromData(Player: Player, GamepassId: number)
    -- TODO once we add a proper data system
end


return GamepassService