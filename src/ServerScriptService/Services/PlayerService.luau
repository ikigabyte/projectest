--!strict
-- File: ServerScriptService/Modules/PlayerService.luau

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

local PlayerService = {}
local DataService = Scrypt.GetService("DataService")

function PlayerService.GetBlockUpgrade(Player: Player): number
    return 1
end

function PlayerService.GetMaxBlocksHold(Player: Player): number
    local Amount = Player:GetAttribute("MaxBlocksHold")
    if not Amount then
        Amount = 2
    end
    return Amount
end

function PlayerService.GetTeam(Player: Player): Team
    return Player.Team
end

function PlayerService.GetBlockSkin(Player : Player)
    return 'Lava'
end

return PlayerService