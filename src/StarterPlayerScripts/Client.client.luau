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
	-- print("updated here")
end)

-- function to convert seconds into a time format (TODO MOVE TO SEPARATE SCRIPT)
local function secondsToTime(seconds: number): string
	local minutes = math.floor(seconds / 60)
	local seconds = seconds % 60
	return string.format("%02d:%02d", minutes, seconds)
end

Scrypt.ClientNetwork.ListenForPacket("UpdateRoundTime", true, function(packetData)
	Scrypt.GUI.GameGui.ProgressFrame.Timer.TimerLabel.Text = secondsToTime(packetData)
end)

task.wait(2)
