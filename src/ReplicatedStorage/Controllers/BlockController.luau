-- V.2.2

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

local ReplicatedStorage : ReplicatedStorage = Scrypt.Services.ReplicatedStorage
local TweenService : TweenService = Scrypt.Services.TweenService
local BlockControler = {}

local AudioController = Scrypt.GetController('AudioController')
local CurrentPlayingAnimation : AnimationTrack

type BlockPacketData = {
    Status: boolean,
    VectorPlacement: Vector3,
    AmmountOfBlocks: IntValue,
}

local function StartTracking()
    -- TODO find the latest hitbox that is available in the staircase model, and you can only place it there
	local connection
	connection = workspace.Bases.Red.StaircaseModel["Hitbox"].Touched:Connect(function(hit: BasePart)--! How about controlling the barrier part on the server so it's moving but it's still tracking the touches
		-- Check if part is the local player
        if not (hit:IsDescendantOf(Scrypt.LocalPlayer.Character) or hit.Parent == Scrypt.LocalPlayer.Character) then return end

		Scrypt.ClientNetwork.SendPacket("Blocktest", {
			Reliable = true, Data = "Red"
		})

		connection:Disconnect()
	end)
end

function BlockControler.HandleBlockPlacement(PlacementVector : Vector3, AmmountOfBlocks : IntValue)
	if CurrentPlayingAnimation then
		CurrentPlayingAnimation:Stop()
	end
    AudioController.PlaySound('BlockPlace', 1, 0, .5, PlacementVector, 0.35) 
    -- print("Placed a block here")
    local CopyPart = Instance.new("Part")
    CopyPart.Parent = workspace
    CopyPart.Size = Vector3.new(2,2,2)
    CopyPart.Position = Scrypt.LocalPlayer.Character.PrimaryPart.Position
    local Tween = TweenService:Create(CopyPart, TweenInfo.new(.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Position = PlacementVector}) --! this is gonna move the thing here 
    Tween:Play(); -- Maybe a way to replicate it to all cleints
    CopyPart.Anchored = true
    CopyPart.CanCollide = false
    Tween.Completed:Connect(function(playbackState)
        -- print("done tweening here")
        CopyPart:Destroy()
    end)
end

function BlockControler.HandleBlocks()
    Scrypt.ClientNetwork.ListenForPacket("BlockTool", true, function(packetData : BlockPacketData) -- We should recieve the team base here
        if packetData.Status == true then
            local BlockToolAnimation = ReplicatedStorage.Assets.Animations.HoldBlock
            local Character = Scrypt.LocalPlayer.Character
            local Humanoid = Character:WaitForChild("Humanoid")
            local Animator : Animator = Humanoid:WaitForChild("Animator")

            CurrentPlayingAnimation = Animator:LoadAnimation(BlockToolAnimation)
            CurrentPlayingAnimation:Play()
            StartTracking()
            return
        elseif packetData.Status == false then
            BlockControler.HandleBlockPlacement(packetData.VectorPlacement)
        end      
    end)
end



return BlockControler