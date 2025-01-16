--!strict


--[[

    - This script serves to handle any currency the player gets or decides to spend in round
    - Currency does not save, round based
    
    
    

]]
local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

local CurrencyService = {}

local PlayerCoins = {}

function CurrencyService.RewardPlayer(Player : Player, BlocksPlaced: number) -- Give the player a certain ammount
    -- local Coins = 
    local AmmtToReward = 10 * BlocksPlaced
    if PlayerCoins[Player] then
        PlayerCoins[Player] = PlayerCoins[Player] + AmmtToReward
    else
        PlayerCoins[Player] = AmmtToReward
    end
	Scrypt.ServerNetwork.SendPacketToClient(
		"CurrencyUpdate",
		{ Address = Player, Data = AmmtToReward, Reliable = true }
	)
    -- TODO Make sure to check if the player has any type of vip

end



function CurrencyService.HandlePurchase(Player : Player, Cost: number)
    



end


function CurrencyService.GetPlayerCurrency(Player : Player)
    return PlayerCoins[Player] or 0 
end
    
return CurrencyService
