--!strict
local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()
--[[
    @ Handles any type of rewards given to the player, this is gems, coins, pets, etc
    @ Plug in Spin the wheel, daily gifts, etc through this service to determine how to procede
]]

local RewardTypes = {'Gems', 'Coins', 'Pets', 'Skin'}

type Reward = {
    Ammount : number | string,
    RewardType : string,
    MultipleClaims : boolean,
}

local RewardService = {}
function RewardService.GiveReward(Player: Player, Reward : Reward)
	print(Reward);
	-- local Data = DataService.GetPlayerDataAsync(Player)
end

return RewardService