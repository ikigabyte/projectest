local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init():Wait()

local Player = Scrypt.LocalPlayer
local ReplicatedStorage: ReplicatedStorage = Scrypt.Services.ReplicatedStorage
local TweenModule = Scrypt.GetModule("TweenService2")



local UIController = Scrypt.GetController("UIController")

Scrypt.ClientNetwork.ListenForPacket("WelcomeMessage", true, function(packetData)
	print("Received welcome message: " .. tostring(packetData))
end)

local BlockController= Scrypt.GetController("BlockController")
BlockController.HandleBlocks();

Scrypt.ClientNetwork.ListenForPacket("CurrencyUpdate", true, function(packetData)
	
	UIController.HandleCurrencyUpdate(packetData)
	-- print("updated here")
end)

Scrypt.ClientNetwork.ListenForPacket("StairProcess", true, function(packetData)
	print("recieved a request to update the progress of the data")
	
end)

Scrypt.ClientNetwork.ListenForPacket("CurrencyUpdate", true, function(packetData)
	Scrypt.GUI.GameGui.Cash.Amount.Text = tostring(packetData)
	print("updated here")
end)


task.wait(2)
