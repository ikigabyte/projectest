--!strict

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

local StairService = {}
local Zone = Scrypt.GetModule("Zone")
local PlayerService = Scrypt.GetService("PlayerService")
local TeamService = Scrypt.GetService("TeamService")
local CurrencyService = Scrypt.GetService("CurrencyService")
local QueueStruct = Scrypt.GetModule("Queue")
local Assets = Scrypt.Services.ReplicatedStorage.Assets

-- EDIT: Moved from RoundService
local BlueQueuePlacement = {
    Processing = false,
    Requests = QueueStruct.new()
}
local RedQueuePlacement = {
    Processing = false,
    Requests = QueueStruct.new()
}

local TeamColors = {
    Red =  Color3.fromRGB(255, 125, 125),
    Blue = Color3.fromRGB(84, 138, 255)
}

type QueueRequest = {
    Player: Player,
    Blocks: number
}

-- Constants
local STUD_HEIGHT_MULTIPLIER = 1
local ROTATION_MIN = -15
local ROTATION_MAX = 15
local PROCESS_DELAY = 0.2
local DEFAULT_SORT_VALUE = 0

-- Sort blocks by name (1, 2, 3, 4, etc)
local function sortBlocksByName(a: Instance, b: Instance): boolean
    local numA = tonumber(a.Name) or DEFAULT_SORT_VALUE
    local numB = tonumber(b.Name) or DEFAULT_SORT_VALUE
    return numA < numB
end

local function equipSkin(block : Part, skinTexture : Texture)
    local NormalIds = {
        Enum.NormalId.Back,
        Enum.NormalId.Bottom,
        Enum.NormalId.Front,
        Enum.NormalId.Left,
        Enum.NormalId.Right,
        Enum.NormalId.Top
    }

    for face = 1, 6, 1 do 
        local textureClone = skinTexture:Clone()
        textureClone.Parent = block
        textureClone.Face = NormalIds[face]
        textureClone.Name = 'Skin'
    end
end

local function createBasicBlock(TeamColor: Color3, Skin: string): BasePart
    local block = Assets:FindFirstChild("StudPart"):Clone()
    block.Anchored = false
    block.CanCollide = false
    block.Color = TeamColor
    
    if Skin ~= 'Default' then
        local SkinAsset = Assets.Textures:FindFirstChild(Skin)
        if SkinAsset then equipSkin(block, SkinAsset) end
    end
    
    return block
end

local function positionAndWeldBlock(baseBlock: BasePart, newBlock: BasePart, index: number, randomGen: Random)
    local studHeightY = newBlock.Size.Y
    newBlock.Position = baseBlock.Position + Vector3.new(0, (studHeightY * index) - studHeightY, 0)
    
    local randomYRotation = randomGen:NextInteger(ROTATION_MIN, ROTATION_MAX)
    newBlock.Orientation += Vector3.new(0, randomYRotation, 0)

    local Weld = Instance.new("WeldConstraint")
    Weld.Parent = newBlock
    Weld.Part0 = baseBlock
    Weld.Part1 = newBlock
end

local function GetBlocksModel(Player: Player, blockUpgrade: number): Model
    local tempModel = Instance.new("Model")
    local Skin = PlayerService.GetBlockSkin(Player)
    local TeamColor = TeamColors[Player.Team.Name] or Color3.new(1, 1, 1)
    local RandomGenerator = Random.new()
    local baseBlock = nil

    for i = 1, blockUpgrade do
        local block = createBasicBlock(TeamColor, Skin)
        block.Parent = tempModel

        if i == 1 then
            baseBlock = block
            tempModel.PrimaryPart = baseBlock
        else
            positionAndWeldBlock(baseBlock, block, i, RandomGenerator)
        end
    end

    return tempModel
end

-- Process block placement
local function processBlock(block: Part, player: Player, hitbox: Part, wall: Part): boolean
    if block.Name == "Hitbox" or block.Name == "Wall" or 
       not block:IsA("Part") or 
       block.CanCollide or 
       block.Transparency ~= 1 then
        return false
    end

    block.CanCollide = true
    block.Transparency = 0
    Scrypt.ServerNetwork.SendPacketToClient("BlockTool", {
        Address = player,
        Data = { Status = false, VectorPlacement = block.Position },
        Reliable = true
    })
    
    -- Check if row is completed
    if (tonumber(block.Name) - 1)%8 == 0 then
        hitbox:PivotTo(block.CFrame*CFrame.new(block.Size.X*0.5, 0, block.Size.Z*0.5))
        wall:PivotTo(block.CFrame*CFrame.new(
            block.Size.X*0.5, -block.Size.Y*0.5, -block.Size.Z*0.5
        )*CFrame.new(
            0, wall.Size.Y*0.5, -wall.Size.Z*0.5
        ))
    end
    
    return true
end

local function GemChance(): boolean
    local Random = Random.new(os.clock()*10000)
    local Chance = Random:NextInteger(0, 10)
    
    return Chance <= 1
end

-- Processes the queue of block placement requests for a specific team
local function processBlockPlacementQueue(queueToProcess: string, staircaseModel: Model)
    -- Get the queue for the specified team
    local queue = (queueToProcess == "Blue") and BlueQueuePlacement or RedQueuePlacement
    
    -- Prevent multiple simultaneous processing of the same queue
    if queue.Processing then return end
    queue.Processing = true

    -- Process queue in a separate thread
    task.defer(function()
        while not queue.Requests:isEmpty() do
            -- Get next request from queue
            local request: QueueRequest = queue.Requests:pop()
            
            if not request then continue end
            
            local player, blocks = request.Player, request.Blocks
            local hitbox = staircaseModel:FindFirstChild("Hitbox")
            local wall = staircaseModel:FindFirstChild("Wall")
            
            -- Validate hitbox exists
            if not hitbox then
                warn("No hitbox found in staircase model")
                continue
            end

            -- Validate wall exists
            if not wall then
                warn("No wall found in staircase model")
                continue
            end
            
            -- Sort blocks numerically by name
            local sortedBlocks = staircaseModel:GetChildren()
            table.sort(sortedBlocks, sortBlocksByName)
            
            -- Give currency reward to player
            CurrencyService.AddRAMCurrencyToPlayer(player, "Coins", blocks*10)
            
            -- Process blocks up to requested amount
            local processedBlocks = 0
            for _, block in ipairs(sortedBlocks) do
                if processBlock(block, player, hitbox, wall) then
                    processedBlocks += 1

                    if GemChance() then
                        print("YOU GOT A GEM")
                        CurrencyService.AddCurrency(player, "Gems", 1)
                    end

                    if processedBlocks >= blocks then break end
                end
            end
            
            -- Log warning if unable to process all requested blocks
            if processedBlocks < blocks then
                warn(string.format(
                    "Queue %s: Requested %d blocks but only processed %d", 
                    queueToProcess, blocks, processedBlocks
                ))
            end
            
            -- Wait before processing next request
            task.wait(PROCESS_DELAY)
        end
        
        -- Mark queue as no longer processing
        queue.Processing = false
    end)
end

-- Helper function to validate the character of a player
local function validateCharacter(Player: Player): boolean
    local Character = Player.Character
    if not Character then
        warn("Character not found for player: " .. Player.Name)
        return false
    end

    local LeftHand = Character.LeftHand
    assert(LeftHand, "LeftHand not found.")

    local LeftGripAttachment: Attachment = LeftHand:FindFirstChild("LeftGripAttachment")
    assert(LeftGripAttachment, "LeftGripAttachment part not found.")

    local UpperTorso = Character:FindFirstChild("UpperTorso")
    assert(UpperTorso, "UpperTorso not found.")

    return true
end

-- Calculate how many blocks to give the player
local function getMaxBlocks(Player: Player, CollectionPart: BasePart)
    local TotalAvailableBlocks = CollectionPart:GetAttribute("BlockCount") or 0
    local BlocksUpgrade = PlayerService.GetMaxBlocksHold(Player) or 1
    local BlocksToGive = math.min(BlocksUpgrade, TotalAvailableBlocks)

    return BlocksToGive
end

local function createBlockTool(Character: Model, Player: Player, BlocksToGive: number): Tool
    -- Create tool
    local BlockTool = Instance.new("Tool")
    BlockTool.Name = "BlockTool"
    BlockTool.Parent = Character
    BlockTool.RequiresHandle = false
    
    local meshModel = GetBlocksModel(Player, BlocksToGive)
    meshModel.Parent = BlockTool
    BlockTool:SetAttribute('BlocksHeld', BlocksToGive)
    
    -- Calculate the offset position (2 studs in front, 2 studs up)
    local BodyFrontAttachment = Character.UpperTorso:FindFirstChild("BodyFrontAttachment")
    local offset = CFrame.new(0, 0, -2) -- Adjusts for the relative position
    meshModel:PivotTo(BodyFrontAttachment.WorldCFrame * offset)
    
    local Weld = Instance.new("WeldConstraint")
    Weld.Part0 = meshModel.PrimaryPart
    Weld.Part1 = BodyFrontAttachment.Parent -- Attach to the UpperTorso
    Weld.Parent = meshModel.PrimaryPart

    return BlockTool
end

-- Handles block placement from the client
local function onBlockCreated(CollectionPart: BasePart): RBXScriptConnection
    local Connection: RBXScriptConnection
    Connection = Scrypt.ServerNetwork.ListenForPacket("PlaceBlock", true, function(Player, Data)
        local Team = tostring(Player.Team)
        local StaircaseModel = TeamService.GetBaseChild(Team, "StaircaseModel")
        local Character = Player.Character
        assert(validateCharacter(Player), "Character validation failed.")
    
        local BlockTool = Character:FindFirstChild("BlockTool")
        if not BlockTool then return end

        local BlocksHeld = BlockTool:GetAttribute("BlocksHeld")
        if BlocksHeld == 0 then return end

        -- Get correct queue based on team
        local Queue = if Team == "Red" then RedQueuePlacement else BlueQueuePlacement
        local PlacementData = {
            Blocks = BlocksHeld,
            Player = Player,
        }

        BlockTool:SetAttribute("BlocksHeld", 0)
        Queue.Requests:push(PlacementData)
        processBlockPlacementQueue(if Team == "Red" then "Red" else "Blue", StaircaseModel)
        BlockTool:Destroy()

        Scrypt.ServerNetwork.PingAllClients("UpdateProgressBar", true)
    end)

    return Connection
end

-- Setup the team zone
local function setupTeamZone(CollectionPart: BasePart): RBXScriptConnection
    -- Spawn in Blocks
    local TeamZone = Zone.fromRegion(CollectionPart.CFrame, Vector3.new(15, 15, 15))
    local Connection
    Connection = TeamZone.playerEntered:Connect(
        function(player: Player) -- Calculate how many the player needs to grab and how many are in the base
            -- print("Player entered the zone")
            if CollectionPart:GetAttribute("BlockCount") == 0 then return end
            StairService.PickupBlocks(player, CollectionPart)
            -- print("Now giving player a block to do something here with")
        end
    )

    return Connection
end

-- Resets a staircase for a team
function StairService.ResetStairs(Team: string)
    local StaircaseModel = TeamService.GetBaseChild(Team, "StaircaseModel")
    local children = StaircaseModel:GetChildren()

    for _, child: BasePart in ipairs(children) do
        if not (child:IsA("BasePart") and child.Name ~= "1" and child.Name ~= "Wall") then continue end
        child.CanCollide = false
        child.Transparency = 1
    end

    local Hitbox = StaircaseModel:FindFirstChild("Hitbox")
    local Wall = StaircaseModel:FindFirstChild("Wall")

    local FirstPart = StaircaseModel:FindFirstChild("1")
    Hitbox:PivotTo(FirstPart.CFrame*CFrame.new(FirstPart.Size.X*0.5, 0, FirstPart.Size.Z*0.5))

    Wall:PivotTo(FirstPart.CFrame*CFrame.new(
        FirstPart.Size.X*0.5, -FirstPart.Size.Y*0.5, -FirstPart.Size.Z*0.5
    )*CFrame.new(
        0, Wall.Size.Y*0.5, -Wall.Size.Z*0.5
    ))
end

function StairService.PickupBlocks(Player: Player, CollectionPart: Part) 
    local Character = Player.Character
    assert(validateCharacter(Player), "Character validation failed.")
    
    local BlocksToGive = getMaxBlocks(Player, CollectionPart)
    if Character:FindFirstChild("BlockTool") then
        local Blocks = Character.BlockTool:GetAttribute("BlocksHeld") + BlocksToGive
        Character.BlockTool:Destroy()
        createBlockTool(Character, Player, Blocks)
    else
        -- Create tool
        createBlockTool(Character, Player, BlocksToGive)
    end
    
    Scrypt.ServerNetwork.SendPacketToClient("BlockTool", {Address = Player, Data = {Status = true}, Reliable = true})
    CollectionPart:SetAttribute("BlockCount", CollectionPart:GetAttribute("BlockCount") - BlocksToGive)
    --TODO ABILITY TO CREATE A STACK OF BLOCKS before giving to the player and then setting a primary part cframe here as well
end

-- Create and place the studs pack / pile
local function CreateStudsPack(CollectionPart: BasePart)
    if CollectionPart.Parent:FindFirstChild("SmallStudPack") then return end
    local SmallStudPack = Assets.SmallStudPack
    SmallStudPack = SmallStudPack:Clone()
    SmallStudPack.Parent = CollectionPart.Parent

    local CollectionCFrame = CFrame.new(CollectionPart.Position + Vector3.new(0,2,0))
    SmallStudPack:PivotTo(CollectionCFrame)
end

-- Start spawning blocks
function StairService.StartSpawning(Team: string) -- ! It has to get both teams and start spawning the blocks in each respective zone
	local CollectionPart: Part = TeamService.GetBaseChild(Team, "CollectionPart"):: Part
    CollectionPart:SetAttribute("BlockCount", 0)

    local Connection = onBlockCreated(CollectionPart)
    local Connection2 = setupTeamZone(CollectionPart)
    local Connection3

    local Studs = CollectionPart.Parent.Upgrades.StudsPerSecond.Value
    CreateStudsPack(CollectionPart)
    
    Connection3 = CollectionPart:GetAttributeChangedSignal("BlockCount"):Connect(function()
        CollectionPart.Info.Frame.Title.Text = CollectionPart:GetAttribute("BlockCount")
    end)
    
    local TRUE = true
    task.defer(function() -- Might have to change this to spawn
        while TRUE do 
            print("Spawning in blocks")
            Studs = CollectionPart.Parent.Upgrades.StudsPerSecond.Value
            CollectionPart:SetAttribute("BlockCount", (CollectionPart:GetAttribute("BlockCount"):: number) + Studs or 1)

            task.wait(2)
        end
    end)

    return function()
        -- Cleanup
        TRUE = false
        Connection:Disconnect()
        Connection2:Disconnect()
        Connection3:Disconnect()
    end
 end

 return StairService

 --! Temporarily disabled this, finding another way to track each clients placement
 -- function StairService.HandleStaircase()
--     -- local Zone = Zone.fromRegion(workspace:FindFirstChild("StaircaseModel"), Vector3.new(15, 15, 15))

--     local StaircaseModel = workspace:FindFirstChild("StaircaseModel"):: Model
--     local ZoneCreator = Zone.fromRegion(StaircaseModel:FindFirstChild("1").CFrame, Vector3.new(15,15,15))
--     print("staircase created")
--     ZoneCreator.playerEntered:Connect(function(Player: Player)
--         local Team = Player.Team
--         local Character = Player.Character
--         if not Character then return end
--         print("Player entered the zone, now placing something here")
--         local BlockTool = Character:FindFirstChild("BlockTool")
--         if not BlockTool then return end -- EDIT: Changed if statement to a guard clause to avoid nesting

--         local Blocks = BlockTool:GetAttribute("BlockUpgrade") or 1
--         print("upgrading the parts here")
--         -- BlockTool:SetAttribute("BlockUpgrade", Upgrade)
--         local Data = {
--             Blocks = Blocks,
--             Player = Player,
--         }
--         table.insert(RedQueuePlacement, Data)
--         print("inserted into the table here")
--         ProcessBlockPlacementQueue("Red", StaircaseModel)
--         -- local part = Instance.new("Part", StaircaseModel)
--         -- part.Size = Vector3.new(1, 1, 1)
--         -- part.Position = StaircaseModel.Position + Vector3.new(0, 1, 0)
--         BlockTool:Destroy()
--     end)
-- end