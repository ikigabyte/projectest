--!strict
-- V.2.2
local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

local ReplicatedStorage: ReplicatedStorage = Scrypt.Services.ReplicatedStorage
local TweenService: TweenService = Scrypt.Services.TweenService
local BlockControler = {}

local AudioController = Scrypt.GetController('AudioController')
local CurrentPlayingAnimation : AnimationTrack

type BlockPacketData = {
    Status: boolean,
    VectorPlacement: Vector3,
    AmmountOfBlocks: IntValue,
}

-- Function to start tracking player touches with the staircase hitbox
local function StartTracking()
    local connection
    connection = workspace.Bases[Scrypt.LocalPlayer.Team.Name].StaircaseModel["Hitbox"].Touched:Connect(function(hit: BasePart)
        -- Skip if the touched part isn't from the local player
        if not (hit:IsDescendantOf(Scrypt.LocalPlayer.Character) or hit.Parent == Scrypt.LocalPlayer.Character) then return end

        -- Send packet to place block when player touches hitbox
        Scrypt.ClientNetwork.SendPacket("PlaceBlock", {
            Reliable = true, Data = Scrypt.LocalPlayer.Team.Name
        })

        -- Disconnect the touch connection after use
        connection:Disconnect()
    end)
end

-- Function to handle visual block placement animation
function BlockControler.HandleBlockPlacement(PlacementVector : Vector3, AmmountOfBlocks : IntValue)
    -- Stop any currently playing animation
    if CurrentPlayingAnimation then
        CurrentPlayingAnimation:Stop()
    end

    -- Play block placement sound effect
    AudioController.PlaySound('BlockPlace', 1, 0, .5, PlacementVector, 0.35) 

    -- Create temporary visual block
    local CopyPart = Instance.new("Part")
    CopyPart.Parent = workspace
    CopyPart.Size = Vector3.new(2,2,2)
    CopyPart.Position = Scrypt.LocalPlayer.Character.PrimaryPart.Position
   
    -- Animate block movement
    local Tween = TweenService:Create(CopyPart, TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Position = PlacementVector})
    Tween:Play()
    CopyPart.Anchored = true
    CopyPart.CanCollide = false

    -- Clean up temporary block after animation
    Tween.Completed:Connect(function(playbackState)
        CopyPart:Destroy()
    end)
end

-- Function to handle block placement system
function BlockControler.HandleBlocks()
    -- Listen for block tool network packets
    Scrypt.ClientNetwork.ListenForPacket("BlockTool", true, function(packetData : BlockPacketData)
        if packetData.Status == true then
            -- Load and play block holding animation
            local BlockToolAnimation = ReplicatedStorage.Assets.Animations.HoldBlock
            local Character = Scrypt.LocalPlayer.Character
            local Humanoid = Character:WaitForChild("Humanoid")
            local Animator: Animator = Humanoid:WaitForChild("Animator")

            CurrentPlayingAnimation = Animator:LoadAnimation(BlockToolAnimation)
            CurrentPlayingAnimation:Play()
            StartTracking()
        elseif packetData.Status == false then
            -- Handle block placement animation
            BlockControler.HandleBlockPlacement(packetData.VectorPlacement)
        end      
    end)
end

return BlockControler