--!strict

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

local StairService = {}
local Zone = Scrypt.GetModule("Zone")
local PlayerService = Scrypt.GetService("PlayerService")
local TeamService = Scrypt.GetService("TeamService")

-- EDIT: Moved from RoundService
local isProcessing = false -- Variable to track if the queue is already being processed
local BlueQueuePlacement = {}
local RedQueuePlacement = {}
local RedTeam = {
    RedQueuePlacement = {},
    StairPlacementZone = nil,
}

-- EDIT: Moved from RoundService
local function ProcessBlockPlacementQueue(QueueToProcess: string)
    -- Determine which queue to process
    local Queue = (QueueToProcess == "Blue") and BlueQueuePlacement or RedQueuePlacement
    -- If the queue is already being processed, return early
    if isProcessing then
        return
    end

    isProcessing = true -- Mark the queue as being processed

    task.defer(function()
        while #Queue > 0 do
            print("Processing the respective queue here")
            -- Take the first request from the queue
            table.remove(Queue, 1)
            -- print(Queue
            local staircase = workspace:FindFirstChild("StaircaseModel"):: Model
            local children = staircase:GetChildren()

            table.sort(children, function(a, b)
                local numA = tonumber(a.Name) or 0 -- Convert to number, default to 0 if not a valid number
                local numB = tonumber(b.Name) or 0
                return numA < numB
            end)
            
            -- EDIT: Changed to ipairs
            for i, child in ipairs(children) do
                if child:IsA("Part") and child.CanCollide == false then 
                    child.Transparency = 0
                    child.CanCollide = true
                    print(child.Name)
                    print("found the child")
                    break
                end
            end
            -- print("Processed the respective queue here")
            task.wait(.2) -- Wait 1 second to simulate processing
        end

        isProcessing = false -- Mark the queue as not being processed
        print("Queue processing complete.")
    end)
end

-- EDIT: Moved from RoundService
function StairService.HandleBlock(Player : Player)
    -- print("Handling block")
    local BlockTool = Instance.new("Tool")
    local Character = Player.Character
    assert(Character, "Character not found.")

    -- EDIT: Added RootPart variable to store the character's primary part
    local RootPart = Character.PrimaryPart
    assert(RootPart, "Root part not found.")

    if Character:FindFirstChild("BlockTool") then
        return
        -- Character.BlockTool:Destroy()
    end

    BlockTool.Name = "BlockTool"
    BlockTool.Parent = Character
    BlockTool.RequiresHandle = false;
    local Upgrade = PlayerService.GetBlockUpgrade(Player)
    BlockTool:SetAttribute("BlockUpgrade", Upgrade)
    local meshPart = Instance.new("Part")
    meshPart.Parent = BlockTool

    -- Put it 2 studs in front of the player 
    meshPart.CFrame = RootPart.CFrame * CFrame.new(0, 0, -2)
    meshPart.CanCollide = false
    meshPart.Size = Vector3.new(1.5, 1.5, 1.5)
    local wc  = Instance.new("WeldConstraint")
    wc.Parent = meshPart
    wc.Part0 = meshPart
    wc.Part1 = RootPart
end

-- EDIT: Moved from RoundService
function StairService.HandleStaircase()
    -- local Zone = Zone.fromRegion(workspace:FindFirstChild("StaircaseModel"), Vector3.new(15, 15, 15))

    local StaircaseModel = workspace:FindFirstChild("StaircaseModel"):: Model
    local ZoneCreator = Zone.fromRegion(StaircaseModel:FindFirstChild("1").CFrame, Vector3.new(15,15,15))
    print("staircase created")

    ZoneCreator.playerEntered:Connect(function(Player: Player)
        local Team = Player.Team
        local Character = Player.Character
        if not Character then return end
        
        print("Player entered the zone, now placing something here")
        local BlockTool = Character:FindFirstChild("BlockTool")
        if not BlockTool then return end -- EDIT: Changed if statement to a guard clause to avoid nesting

        local Blocks = BlockTool:GetAttribute("BlockUpgrade") or 1
        print("upgrading the parts here")
        -- BlockTool:SetAttribute("BlockUpgrade", Upgrade)
        local Data = {
            Blocks = Blocks,
            Player = Player,
        }
        table.insert(RedQueuePlacement,"RedQueuePlacement")
        ProcessBlockPlacementQueue("Red")
        -- local part = Instance.new("Part", StaircaseModel)
        -- part.Size = Vector3.new(1, 1, 1)
        -- part.Position = StaircaseModel.Position + Vector3.new(0, 1, 0)
        BlockTool:Destroy()
    end)
    

end

-- EDIT: Moved from RoundService
function StairService.StartSpawning()
    local CollectionPart : Part =  TeamService.GetBaseChild("Red", "CollectionPart"):: Part
    -- Spawn in Blocks
     local TeamZone = Zone.fromRegion(CollectionPart.CFrame, Vector3.new(15,15,15))
     TeamZone.playerEntered:Connect(function(player)
         StairService.HandleBlock(player)
         -- print(TeamZone)
         print("Now giving player a block to do something here with")
     end)
 
     
 --    print(CollectionPart)
    while true do 
         -- print("spawning in a brick ehre")
         local part = Instance.new("Part", CollectionPart)
         part.Size = Vector3.new(1, 1, 1)
         part.Parent = workspace
         part.Position = CollectionPart.Position + Vector3.new(0, 1, 0)
         
         task.wait(1) -- EDIT: Moved this out of the while loop condition to fit best practices
    end
 end

 return StairService