--!strict
-- File: ServerScriptService/Modules/GameModule.luau

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

local PlayerService = {}



function PlayerService.GetBlockUpgrade(Player: Player)

    return 1


end


return PlayerService