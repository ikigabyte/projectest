local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init():Wait()

local Player = Scrypt.LocalPlayer
local ReplicatedStorage: ReplicatedStorage = Scrypt.Services.ReplicatedStorage
local TweenModule = Scrypt.GetModule("TweenService2")
local GameConfig = Scrypt.GetModule("GameConfig")
local TextChatService = Scrypt.Services.TextChatService

local BlockController = Scrypt.GetController("BlockController")
local UIController = Scrypt.GetController("UIController")
local ZoneController = Scrypt.GetController("ZoneController")


-- local test = Scrypt.ClientNetwork.EmptyRequest('GetPlayerCoins')
BlockController.HandleBlocks()
UIController.SetupTopBarFeatures()


-- Counts the number of valid stairs in a team's staircase
local function CountTeamProgress(team: string)
	local teamProgress = 0
	
	-- Find the team's base folde
	local teamFolder = workspace.Bases:FindFirstChild(team)
	assert(teamFolder, "Team folder not found")

	-- Find the staircase model
	local Staircase = teamFolder:FindFirstChild("StaircaseModel")
	assert(Staircase, "Staircase not found")

	-- Count each valid stair (visible and collidable)
	for _, stair in ipairs(Staircase:GetChildren()) do
		if not stair:IsA("BasePart") then continue end
		if stair.Transparency == 1 then continue end
		if not stair.CanCollide then continue end

		teamProgress += 1
	end

	return teamProgress
end

-- Calculates the progress percentage for a team
local function GetTeamProgress(team: string): number
	local teamProgress = CountTeamProgress(team)
	local Total = GameConfig.TotalStairs
	local Progress = teamProgress / Total
	return Progress
end


-- Updates the UI progress bars for both teams
local function UpdateProgressBar()
	-- Get progress for both teams
	local RedProgress = GetTeamProgress("Red")
	local BlueProgress = GetTeamProgress("Blue")

	-- Create gradient for Red team progress bar
	local RedProgressBar = if RedProgress < 1 then NumberSequence.new(
		{
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(RedProgress-0.001, 0),
			NumberSequenceKeypoint.new(RedProgress, 1),
			NumberSequenceKeypoint.new(1, 1)
		}
	) else NumberSequence.new(
		1 - RedProgress
	)

	-- Create gradient for Blue team progress bar
	local BlueProgressBar = if BlueProgress < 1 then NumberSequence.new(
		{
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(BlueProgress-0.001, 0),
			NumberSequenceKeypoint.new(BlueProgress, 1),
			NumberSequenceKeypoint.new(1, 1)
		}
	) else NumberSequence.new(
		1 - BlueProgress
	)

	-- Update UI elements with new progress values
	Scrypt.GUI.GameGui.ProgressFrame.Red.ImageLabel.UIGradient.Transparency = RedProgressBar
	Scrypt.GUI.GameGui.ProgressFrame.Blue.ImageLabel.UIGradient.Transparency = BlueProgressBar

	-- Update progress percentage labels
	Scrypt.GUI.GameGui.ProgressFrame.Red.ProgressLabel.Text = string.format("%.0f%%", RedProgress*100)
	Scrypt.GUI.GameGui.ProgressFrame.Blue.ProgressLabel.Text = string.format("%.0f%%", BlueProgress*100)
end

Scrypt.ClientNetwork.ListenForPacket("WelcomeMessage", true, function(packetData)
	print("Received welcome message: " .. tostring(packetData))
end)

Scrypt.ClientNetwork.ListenForPacket("CurrencyUpdate", true, function(packetData)
	UIController.HandleCurrencyUpdate(packetData)
end)

Scrypt.ClientNetwork.ListenForPacket("StairProcess", true, function(packetData)
	print("recieved a request to update the progress of the data")
	
end)

Scrypt.ClientNetwork.ListenForPacket("CurrencyUpdate", true, function(packetData)
	Scrypt.GUI.GameGui.Cash.Amount.Text = tostring(packetData)
end)

-- function to convert seconds into a time format (TODO MOVE TO SEPARATE SCRIPT)
local function FormatToMinutes(Seconds: number): string
	assert(Seconds and typeof(Seconds) == "number", "'Seconds' is not valid")
	
	local Minutes = math.floor((Seconds % 3600) / 60)
	local RemainingSeconds = Seconds % 60

	return string.format("%02d:%02d", Minutes, RemainingSeconds)
end

--! Figure out what the message is here and update the ROUND THING

Scrypt.ClientNetwork.ListenForPacket("UpdateRoundTime", true, function(packetData)
	-- Scrypt.GUI.GameGui.ProgressFrame.Timer.TimerLabel.Text = FormatToMinutes(packetData)
end)

Scrypt.ClientNetwork.ListenForPacket("UpdateProgressBar", true, UpdateProgressBar)


UIController.SetupHoverAnimation(Scrypt.GUI.MainGui.Buttons.Skins)
UIController.SetupHoverAnimation(Scrypt.GUI.MainGui.Buttons.Shop)
UIController.SetupHoverAnimation(Scrypt.GUI.MainGui.Buttons.SwitchTeams)


Scrypt.ClientNetwork.ListenForPacket("ServerMessage", true, function(packetData)
	print(packetData);
	local props = packetData.Properties
	local message = packetData.Message
    local textChatMessageProperties = Instance.new("TextChatMessageProperties")
    local PlayerColor = tostring(Player.Team)
    if PlayerColor ~= "Red" and PlayerColor ~= "Blue" then
        return
    end
    local formattedMessage = "<font color='rgb(255, 0, 0)'>[SERVER]</font> " .. message
    TextChatService:DisplaySystemMessage(formattedMessage)
	print("Received server message: " .. message)
end)


ZoneController.InitateAllZones()


-- You have to carefully setup the big market across these regions

-- Zone.fromRegion(game.Workspace.BigMarket)