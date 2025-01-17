--!strict


--[[

    - This script serves to handle any currency the player gets or decides to spend in round
    - Currency does not save, round based
    
    
    

]]
local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

local CurrencyService = {}

local PlayerCoins: {[Player]: number} = {}

function CurrencyService.RewardPlayer(Player : Player, BlocksPlaced: number) -- Give the player a certain ammount
    -- local Coins = 
    local AmountToReward = 10 * BlocksPlaced
    if PlayerCoins[Player] then
        PlayerCoins[Player] = PlayerCoins[Player] + AmountToReward
    else
        PlayerCoins[Player] = AmountToReward
    end
    
	Scrypt.ServerNetwork.SendPacketToClient(
		"CurrencyUpdate",
		{ Address = Player, Data = AmountToReward, Reliable = true }
	)
    -- TODO Make sure to check if the player has any type of vip

end

function CurrencyService.RemovePlayerCurrency(Player: Player, Amount: number)
    if not PlayerCoins[Player] then return 0 end
    PlayerCoins[Player] -= Amount
end


function CurrencyService.HandlePurchase(Player: Player, Cost: number): boolean
    if not PlayerCoins[Player] then return false end

    if PlayerCoins[Player] >= Cost then
        PlayerCoins[Player] -= Cost
        return true
    end

    return false
end

function CurrencyService.GetPlayerCurrency(Player: Player): number
    return PlayerCoins[Player] or 0 
end

    
return CurrencyService
