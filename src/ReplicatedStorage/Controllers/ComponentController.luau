-- V.2.2

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()


local TweenService : TweenService = Scrypt.Services.TweenService
local UIController = {}
local AudioController = Scrypt.GetController("AudioController")
local MouseHoverController = Scrypt.GetController("MouseController")
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
    -- print(status)
    icon:setImage(status and muteMusic or music)
end

local function TurnOffAllFrames()
    
    
end

local function TurnOnRespectiveFrame(frameName : string)
    local GUI = Scrypt.GUI[frameName]
    assert(GUI, "Frame not found, skip")
    if GUI then
        GUI.Visible = true
        print("turning on this thing here")
    end 

end

local function onMouseEnter(buttonUI : ImageButton)
    local Props = {
        Rotation = 15,
        Size = UDim2.fromScale(.9,.9)
    }
    local Tween = TweenService:Create(buttonUI.Icon, TweenInfo.new(0.1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), Props)
    buttonUI.Icon.UIGradient.Enabled = true
    buttonUI.Title.Visible = true
    Tween:Play()
    local CleanupFunction : RBXScriptConnection
    CleanupFunction = function()
        print("this has activated here")
        buttonUI.Icon.UIGradient.Enabled = false
        buttonUI.Title.Visible = false
        if Tween.PlaybackState == Enum.PlaybackState.Playing then
            Tween:Cancel()
        end
        buttonUI.Icon.Size = UDim2.fromScale(.8,.8)
        buttonUI.Icon.Rotation = 0
    end
    return CleanupFunction

    --! Return here the stuff here
end
local function StartPlayingMusic(music)
    AudioController.PlaySound(music, .5, 0, .5)
    -- AudioController.LoopSound(music, .5)
    
end


local function AnimateTopBarLabelText(icon, fullText: string)
    local textLength = #fullText
    local scrollSpeed = 0.15 -- Time interval for each update
    local visibleLength = 15 -- Number of visible characters at once
    local timeBeforeHide = 3
    local isActive = true
    -- Function to loop the text
    
    local function loopText()
        while isActive do
            for i = 0, textLength do
                local displayedText = fullText:sub(i + 1, i + visibleLength) -- Create the visible slice
                if #displayedText < visibleLength then
                    -- Append characters from the start to loop seamlessly
                    displayedText = displayedText .. fullText:sub(1, visibleLength - #displayedText)
                end
                icon:setLabel(displayedText)
                task.wait(scrollSpeed)
                if not isActive then icon:setLabel('') break end
            end
        end
    end
    task.delay(timeBeforeHide, function()
        isActive = false -- Cancel the loop
        icon:setLabel('') -- Clear the label
    end)
    loopText()
end

local function HandleMainSong(muteMusicIcon)
    AudioController.PlaySound('MainSong', .5, 0, .5) 
    AudioController.LoopSound('MainSong', .5) 
    local Text = 'Now Playing: ' .. 'Nitro Fun Easter Egg'
    task.spawn(function()
        AnimateTopBarLabelText(muteMusicIcon, Text)
    end)
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



function UIController.SetupHoverAnimation(Button : ImageButton)
    local MouseEnter, MouseLeave = MouseHoverController.MouseEnterLeaveEvent(Button)
    local FrameName = Button:GetAttribute("FrameName") or Button.Name
    -- TurnOnRespectiveFrame(FrameName) //! Temporarily disabled for now until the uis are in place
    local CleanupFunction
    MouseEnter:Connect(function()
        CleanupFunction = onMouseEnter(Button)
    end)
    MouseLeave:Connect(function()
        -- print("Mouse Left")
        if CleanupFunction ~= nil then
            CleanupFunction()    
        end
    end)
end




UIController.SetupTopBarFeatures = function()
    local TopbarPlus = require(Scrypt.Services.ReplicatedStorage:FindFirstChild("TopbarPlus"):FindFirstChild("Icon"))
    -- local icon = TopbarPlus.new:setImage(asset)

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
    -- print("set up all the top bar features here")

    local muteMusicIcon
    muteMusicIcon = TopbarPlus.new()
    :setImage(music)
    

    task.delay(1, function()
        HandleMainSong(muteMusicIcon)
    end)
    muteMusicIcon.deselected:Connect(function()
        OnButtonClick(muteMusicIcon)
    end)
    muteMusicIcon.selected:Connect(function()
        OnButtonClick(muteMusicIcon)
    end)



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