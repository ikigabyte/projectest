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
local isProcessing = false -- Variable to track if the queue is already being processed
local BlueQueuePlacement = {
    Processing = false,
    Requests = QueueStruct.new()
}
local RedQueuePlacement = {
    Processing = false,
    Requests = QueueStruct.new()
}
local RedTeam = {
    RedQueuePlacement = {},
    StairPlacementZone = nil,
}

local function ProcessBlockPlacementQueue(QueueToProcess: string, StaircaseModel: Model)
    local Queue = (QueueToProcess == "Blue") and BlueQueuePlacement or RedQueuePlacement
    
    if Queue.Processing then
        warn(QueueToProcess.." queue is already processing")
        return
    end
    Queue.Processing = true

    task.defer(function()
        print(true)
        while not Queue.Requests:isEmpty() do
            local request = Queue.Requests:pop()
            
            -- Validate request
            if not request then
                warn("Invalid request received in "..QueueToProcess.." queue")
                continue
            end
            
            local Player = request.Player
            local Blocks = request.Blocks
            
            -- Debug logging
            print(string.format("Processing %d blocks for %s", Blocks, Player.Name))
            
            local children = StaircaseModel:GetChildren()
            table.sort(children, function(a, b)
                local numA = tonumber(a.Name) or 0
                local numB = tonumber(b.Name) or 0
                return numA < numB
            end)
            print("RUNNING")
            CurrencyService.RewardPlayer(Player, Blocks)
            
            local processedBlocks = 0
            for _, child in ipairs(children) do
                if child.Name == "Hitbox" then continue end
                if child:IsA("Part") and not child.CanCollide and child.Transparency == 1 then
                    child.CanCollide = true
                    child.Transparency = 0
                    Scrypt.ServerNetwork.SendPacketToClient(
                        "BlockTool",
                        { Address = Player, Data = { Status = false, VectorPlacement = child.Position }, Reliable = true }
                    )
                    processedBlocks += 1
                    StaircaseModel:FindFirstChild("Hitbox"):PivotTo(child.CFrame)
                    if processedBlocks >= Blocks then
                        break
                    end
                end
            end
            
            if processedBlocks < Blocks then
                warn(string.format("Queue %s: Requested %d blocks but only processed %d", 
                    QueueToProcess, Blocks, processedBlocks))
            end
            
            task.wait(0.2)
        end
        
        Queue.Processing = false
        print(QueueToProcess.." queue processing complete")
    end)
end

function StairService.ResetStairs(Team: string)
    local StaircaseModel = TeamService.GetBaseChild(Team, "StaircaseModel")
    local children = StaircaseModel:GetChildren()

    for _, child: BasePart in ipairs(children) do
        if child.CanCollide and child.Transparency == 0 then
            child.CanCollide = false
            child.Transparency = 1
        end
    end
end

-- EDIT: Moved from RoundService
function StairService.HandleBlock(Player : Player)
    local BlockTool = Instance.new("Tool")
    local Character = Player.Character
    assert(Character, "Character not found.")

    local RootPart = Character.PrimaryPart
    assert(RootPart, "Root part not found.")

    if Character:FindFirstChild("BlockTool") then
        return
        -- Character.BlockTool:Destroy()
    end

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
    -- print("the player has been pinged here")
    --TODO ABILITY TO CREATE A STACK OF BLOCKS before giving to the player and then setting a primary part cframe here as well
end

function StairService.StartSpawning() -- ! It has to get both teams and start spawning the blocks in each respective zone
	local CollectionPart: Part = TeamService.GetBaseChild("Red", "CollectionPart") :: Part
    CollectionPart:SetAttribute("BlockCount", 0)

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
        local PlacementData = {
            Blocks = CollectionPart:GetAttribute("BlockCount"),
            Player = Player,
        }
    
        -- Push to queue instead of table.insert
        Queue.Requests:push(PlacementData)
        
        -- Process queue with correct team name
        ProcessBlockPlacementQueue(Team == "Red" and "Red" or "Blue", StaircaseModel)
        
        BlockTool:Destroy()
    end)

	-- Spawn in Blocks
	local TeamZone = Zone.fromRegion(CollectionPart.CFrame, Vector3.new(15, 15, 15))
	TeamZone.playerEntered:Connect(
		function(player: Player) -- Calculate how many the player needs to grab and how many are in the base
			StairService.HandleBlock(player)
			print("Now giving player a block to do something here with")
		end
	)
    
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
