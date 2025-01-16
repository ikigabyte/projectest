--!strict
local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init():Wait()

local Player = Scrypt.LocalPlayer
local PlayerGui = Player.PlayerGui
local GameGui : ScreenGui = PlayerGui.GameGui

local ReplicatedStorage : ReplicatedStorage = Scrypt.Services.ReplicatedStorage

Scrypt.ClientNetwork.ListenForPacket("WelcomeMessage", true, function(packetData)
	print("Received welcome message: " .. tostring(packetData))
end)

local BlockController= Scrypt.GetController("BlockController")
BlockController.HandleBlocks();

local Gui = Scrypt.GUI
print(Gui)


Scrypt.ClientNetwork.ListenForPacket("CurrencyUpdate", true, function(packetData)
	-- print(Scrypt.GUI.Buttons)
	PlayerGui.GameGui.Cash.Amount.Text = tostring(packetData)
	print("updated here")
end)






Scrypt.ClientNetwork.ListenForPacket("StairProcess", true, function(packetData)
	print("recieved a request to update the progress of the data")
	
end)


Scrypt.ClientNetwork.ListenForPacket("CurrencyUpdate", true, function(packetData)
	-- print(Scrypt.GUI.Buttons)
	PlayerGui.GameGui.Cash.Amount.Text = tostring(packetData)
	print("updated here")
end)

