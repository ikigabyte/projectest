-- V.2.2

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()


local UIController = {}




UIController.HandleCurrencyUpdate  = function(Ammt: number)
    print(Scrypt.GUI)
    -- local Currency = Scrypt.GUI.Currency
    -- Currency.Text = tostring(Ammt)
end


return UIController