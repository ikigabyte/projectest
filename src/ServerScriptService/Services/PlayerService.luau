--!strict
-- File: ServerScriptService/Modules/PlayerService.luau

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

local PlayerService = {}

function PlayerService.GetBlockUpgrade(Player: Player): number
    return 1
end

function PlayerService.GetMaxBlocksHold(Player: Player): number
    local Amount = Player:GetAttribute("MaxBlocksHold")

    if not Amount then
        Amount = 6
    end

    return Amount
end

function PlayerService.GetTeam(Player: Player): Team
    return Player.Team
end

function PlayerService.GetData(Player: Player)
    
end

return PlayerService