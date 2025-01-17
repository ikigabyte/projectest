-- V.2.2

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

local TopbarPlus = require(Scrypt.Services.ReplicatedStorage:WaitForChild("TopbarPlus"):WaitForChild("Icon"))

local TweenService : TweenService = Scrypt.Services.TweenService
local UIController = {}

local PlayerSettings = {
    SFX = true,
	MUSIC = true,
}
local music = "rbxassetid://113748648632937"
local muteMusic = "rbxassetid://121000796688227"
local rewardAsset = "rbxassetid://129074893657038"


local status = false
local function OnButtonClick(icon)
    status = not status
    print(status)
    icon:setImage(status and muteMusic or music)
end

UIController.SpawnRandomCoins = function(numberOfIcons, iconOfCurrency: ImageLabel, framePositionAndCapture: Frame, finalPosition: UDim2)
    for i = 1, numberOfIcons do
        -- Clone and configure the icon
        local icon = iconOfCurrency:Clone()
        icon.Parent = framePositionAndCapture
        icon.Size = UDim2.new(0, 50, 0, 50)
        icon.ZIndex = 2
        icon.Visible = true

        -- Center the icon in the frame
        icon.Position = UDim2.new(0.5, -icon.Size.X.Offset / 2, 0.5, -icon.Size.Y.Offset / 2)

        -- Calculate random positions within the frame's bounds
        local randomX = math.random(0, framePositionAndCapture.AbsoluteSize.X - icon.Size.X.Offset)
        local randomY = math.random(0, framePositionAndCapture.AbsoluteSize.Y - icon.Size.Y.Offset)
        local randomPosition = UDim2.new(0, randomX, 0, randomY)

        -- Tween to the random position
        local TweenToRandom = TweenService:Create(
            icon,
            TweenInfo.new(.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Position = randomPosition }
        )

        -- Tween to the final position (zoom-in effect)
        local TweenToFinal = TweenService:Create(
            icon,
            TweenInfo.new(.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
            { Position = finalPosition, Size = UDim2.fromScale(0,0) } -- Adjust final size if needed
        )
        task.wait(0.03)
        -- Chain the tweens
        TweenToRandom:Play()
        TweenToRandom.Completed:Connect(function()
            task.wait(.4)
            TweenToFinal:Play()
        end)
    end
end
UIController.UpdateTimerLabel = function(number)
    Scrypt.GUI.GameGui.ProgressFrame.Timer.TimerLabel.Text = number
end

UIController.SetupTopBarFeatures = function()
    -- local icon = TopbarPlus.new:setImage(asset)
    local muteMusicIcon
    muteMusicIcon = TopbarPlus.new()
    :setImage(music)
    muteMusicIcon.deselected:Connect(function()
        OnButtonClick(muteMusicIcon)
    end)
    muteMusicIcon.selected:Connect(function()
        OnButtonClick(muteMusicIcon)
    end)

    local muteSFXIcon
    muteSFXIcon = TopbarPlus.new()
    :setImage(music)
    muteSFXIcon.deselected:Connect(function()
        OnButtonClick(muteSFXIcon)
    end)
    muteSFXIcon.selected:Connect(function()
        OnButtonClick(muteSFXIcon)
    end)

    local rewardIcon
    rewardIcon = TopbarPlus.new()
    :setImage(rewardAsset)
    rewardIcon:setLabel("Rewards")
    print("set up all the top bar features here")

end

UIController.HandleCurrencyUpdate  = function(Ammount: numberincreaseOrDecrease)
    -- print(Scrypt.GUI)
    local PreviousAmmt = Scrypt.GUI.GameGui.Cash.Amount.Text

    Scrypt.GUI.GameGui.Cash.Amount.Text = tostring(Ammount)
	UIController.SpawnRandomCoins(
		10,
		Scrypt.GUI.GameGui.CaptureZone.Icon,
		Scrypt.GUI.GameGui.CaptureZone,
		Scrypt.GUI.GameGui.Cash.Position
	)
    -- local Currency = Scrypt.GUI.Currency
    -- Currency.Text = tostring(Ammt)
end


return UIController