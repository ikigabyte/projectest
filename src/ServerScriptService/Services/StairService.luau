--!strict

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

local StairService = {}
local Zone = Scrypt.GetModule("Zone")
local PlayerService = Scrypt.GetService("PlayerService")
local TeamService = Scrypt.GetService("TeamService")
local CurrencyService = Scrypt.GetService("CurrencyService")
local QueueStruct = Scrypt.GetModule("Queue")

-- EDIT: Moved from RoundService
local BlueQueuePlacement = {
    Processing = false,
    Requests = QueueStruct.new()
}
local RedQueuePlacement = {
    Processing = false,
    Requests = QueueStruct.new()
}

type QueueRequest = {
    Player: Player,
    Blocks: number
}

local PROCESS_DELAY = 0.2
local DEFAULT_SORT_VALUE = 0

-- Sort blocks by name (1, 2, 3, 4, etc)
local function sortBlocksByName(a: Instance, b: Instance): boolean
    local numA = tonumber(a.Name) or DEFAULT_SORT_VALUE
    local numB = tonumber(b.Name) or DEFAULT_SORT_VALUE
    return numA < numB
end

-- Process block placement
local function ProcessBlock(block: Part, player: Player, hitbox: Part, wall: Part): boolean
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

-- Processes the queue of block placement requests for a specific team
local function ProcessBlockPlacementQueue(queueToProcess: string, staircaseModel: Model)
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
            CurrencyService.RewardPlayer(player, blocks)
            
            -- Process blocks up to requested amount
            local processedBlocks = 0
            for _, block in ipairs(sortedBlocks) do
                if ProcessBlock(block, player, hitbox, wall) then
                    processedBlocks += 1
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

function StairService.ResetStairs(Team: string)
    local StaircaseModel = TeamService.GetBaseChild(Team, "StaircaseModel")
    local children = StaircaseModel:GetChildren()

    for _, child: BasePart in ipairs(children) do
        if child:IsA("BasePart") and child.Name ~= "1" and child.Name ~= "Wall" then
            child.CanCollide = false
            child.Transparency = 1
        end
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

function StairService.HandleBlock(Player : Player)
    local BlockTool = Instance.new("Tool")
    local Character = Player.Character
    assert(Character, "Character not found.")

    local RootPart = Character.PrimaryPart
    assert(RootPart, "Root part not found.")

    if Character:FindFirstChild("BlockTool") then return end

    BlockTool.Name = "BlockTool"
    BlockTool.Parent = Character
    BlockTool.RequiresHandle = false

    local Upgrade = PlayerService.GetBlockUpgrade(Player)
    BlockTool:SetAttribute("BlockUpgrade", Upgrade)

    local meshPart = Instance.new("Part")
    meshPart.Parent = BlockTool

    --TODO  Put it 2 studs in front of the player, then send an event to the player to execute an animation
    meshPart.CFrame = RootPart.CFrame * CFrame.new(0, 0, -2)
    meshPart.CanCollide = false
    meshPart.Size = Vector3.new(1.5, 1.5, 1.5)

    local weld  = Instance.new("WeldConstraint")
    weld.Parent = meshPart
    weld.Part0 = meshPart
    weld.Part1 = RootPart 

    Scrypt.ServerNetwork.SendPacketToClient("BlockTool", {Address = Player, Data = {Status = true}, Reliable = true})
    --TODO ABILITY TO CREATE A STACK OF BLOCKS before giving to the player and then setting a primary part cframe here as well
end

local function OnBlockCreated(CollectionPart: BasePart): RBXScriptConnection
    local Connection: RBXScriptConnection
    Connection = Scrypt.ServerNetwork.ListenForPacket("Blocktest", true, function(Player, Data)
        local Team = tostring(Player.Team)
        local StaircaseModel = TeamService.GetBaseChild(Team, "StaircaseModel")
        local Character = Player.Character
        
        if not Character then 
            warn("No character found for player", Player.Name)
            return 
        end
    
        local BlockTool = Character:FindFirstChild("BlockTool")
        if not BlockTool then 
            warn("No BlockTool found for player", Player.Name)
            return 
        end
    
        -- Get correct queue based on team
        local Queue = Team == "Red" and RedQueuePlacement or BlueQueuePlacement
        local BlockAmount = math.min(CollectionPart:GetAttribute("BlockCount"):: number, PlayerService.GetMaxBlocksHold(Player))
        local PlacementData = {
            Blocks = BlockAmount,
            Player = Player,
        }
    
        -- Push to queue instead of table.insert
        Queue.Requests:push(PlacementData)
        
        -- Process queue with correct team name
        ProcessBlockPlacementQueue(Team == "Red" and "Red" or "Blue", StaircaseModel)
        CollectionPart:SetAttribute("BlockCount", (CollectionPart:GetAttribute("BlockCount"):: number) - BlockAmount)
        BlockTool:Destroy()
    end)

    return Connection
end

local function SetupTeamZone(CollectionPart: BasePart): RBXScriptConnection
    -- Spawn in Blocks
    local TeamZone = Zone.fromRegion(CollectionPart.CFrame, Vector3.new(15, 15, 15))
    local Connection
    Connection = TeamZone.playerEntered:Connect(
        function(player: Player) -- Calculate how many the player needs to grab and how many are in the base
            StairService.HandleBlock(player)
            -- print("Now giving player a block to do something here with")
        end
    )

    return Connection
end

function StairService.StartSpawning() -- ! It has to get both teams and start spawning the blocks in each respective zone
	local CollectionPart: Part = TeamService.GetBaseChild("Red", "CollectionPart") :: Part
    CollectionPart:SetAttribute("BlockCount", 0)

    local Connection = OnBlockCreated(CollectionPart)
    local Connection2 = SetupTeamZone(CollectionPart)
    
    local TRUE = true
    local Studs = CollectionPart.Parent.Upgrades.StudsPerSecond.Value
    task.defer(function()
        while TRUE do 
            Studs = CollectionPart.Parent.Upgrades.StudsPerSecond.Value
            CollectionPart:SetAttribute("BlockCount", (CollectionPart:GetAttribute("BlockCount"):: number) + Studs or 1)
            task.wait(1)
        end
    end)

    return function()
        -- Cleanup
        TRUE = false
        Connection:Disconnect()
        Connection2:Disconnect()
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
