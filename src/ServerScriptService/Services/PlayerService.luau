--!strict
-- File: ServerScriptService/Modules/PlayerService.luau

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

local PlayerService = {}

function PlayerService.GetBlockUpgrade(Player: Player): number
    return 1
end

function PlayerService.GetTeam(Player: Player): Team
    return Player.Team
end

function PlayerService.GetData(Player: Player)
    
end

return PlayerService