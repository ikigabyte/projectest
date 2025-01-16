--!strict

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

local StairService = {}
local Zone = Scrypt.GetModule("Zone")
local PlayerService = Scrypt.GetService("PlayerService")
local ServerScriptService = game:GetService("ServerScriptService")
local TeamService = Scrypt.GetService("TeamService")

local CurrencyService = Scrypt.GetService("CurrencyService")


-- EDIT: Moved from RoundService
local isProcessing = false -- Variable to track if the queue is already being processed
local BlueQueuePlacement = {
    Processing = false,
    Requests = {}
}
local RedQueuePlacement = {
    Processing = false,
    Requests = {}
}
local RedTeam = {
    RedQueuePlacement = {},
    StairPlacementZone = nil,
}


-- EDIT: Moved from RoundService
local function ProcessBlockPlacementQueue(QueueToProcess: string ,StaircaseModel : Model) -- TODO To seperate these into different functions
    -- Determine which queue to process
    local Queue = (QueueToProcess == "Blue") and BlueQueuePlacement or RedQueuePlacement
    -- If the queue is already being processed, return early
    
    if Queue.Processing then
        print("this queue is processing here")
        return
    end
    Queue.Processing = true -- Mark the queue as being processed
    task.defer(function()
        local QueueRequests = Queue.Requests
        print(#QueueRequests)
        
        while #QueueRequests > 0 do
            local Player = QueueRequests[1].Player
            local Blocks = QueueRequests[1].Blocks
            print(Blocks)
            print(Player)
            print("processing the queue here")
            -- Take the first request from the queue
            table.remove(Queue.Requests, 1)
            local children = StaircaseModel:GetChildren()
            table.sort(children, function(a, b)
                local numA = tonumber(a.Name) or 0 -- Convert to number, default to 0 if not a valid number
                local numB = tonumber(b.Name) or 0
                return numA < numB
            end)

            CurrencyService.RewardPlayer(Player, Blocks)
            -- EDIT: Changed to ipairs
            local processedBlocks = 0 -- Track the number of blocks processed
            for _, child in ipairs(children) do
                if child:IsA("Part") and not child.CanCollide and child.Transparency == 1 then
                    -- Modify the properties of the block
                    child.CanCollide = true
                    child.Transparency = 0
					Scrypt.ServerNetwork.SendPacketToClient(
						"BlockTool",
						{ Address = Player, Data = { Status = false, VectorPlacement = child.Position }, Reliable = true }
					)
                    processedBlocks += 1 -- Increment the counter
                    if processedBlocks >= Blocks then
                        break
                    end
                end
            end
            if processedBlocks < Blocks then
                warn("Not enough blocks available to process the requested amount: " .. Blocks)
            end
            -- print("Processed the respective queue here")
            task.wait(.2) -- Wait 1 second to simulate processing
        end
        Queue.Processing = false -- Mark the queue as not being processed
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
    BlockTool.RequiresHandle = false
    local Upgrade = PlayerService.GetBlockUpgrade(Player)
    BlockTool:SetAttribute("BlockUpgrade", Upgrade)
    local meshPart = Instance.new("Part")
    meshPart.Parent = BlockTool

    --TODO  Put it 2 studs in front of the player, then send an event to the player to execute an animation
    meshPart.CFrame = RootPart.CFrame * CFrame.new(0, 0, -2)
    meshPart.CanCollide = false
    meshPart.Size = Vector3.new(1.5, 1.5, 1.5)

    local wc  = Instance.new("WeldConstraint")
    wc.Parent = meshPart
    wc.Part0 = meshPart
    wc.Part1 = RootPart 

    Scrypt.ServerNetwork.SendPacketToClient("BlockTool", {Address = Player, Data = {Status = true}, Reliable = true})
    -- print("the player has been pinged here")
    --TODO ABILITY TO CREATE A STACK OF BLOCKS before giving to the player and then setting a primary part cframe here as well
end

-- EDIT: Moved from RoundService


-- EDIT: Moved from RoundService
function StairService.StartSpawning() -- ! It has to get both teams and start spawning the blocks in each respective zone
	Scrypt.ServerNetwork.ListenForPacket("Blocktest", true, function(Player, Data)
		local Team = tostring(Player.Team)
		local StaircaseModel = TeamService.GetBaseChild(Team, "StaircaseModel")
		local Character = Player.Character
		if not Character then
			return
		end
		local BlockTool = Character:FindFirstChild("BlockTool")
		if not BlockTool then
			return
		end -- EDIT: Changed if statement to a guard clause to avoid nesting
		BlockTool:Destroy()
		local QueueTeamType = Team == "Red" and "RedQueuePlacement" or "BlueQueuePlacement"
		local PlacementData = {
			Blocks = 1,
			Player = Player,
		}

		table.insert(RedQueuePlacement.Requests, PlacementData)
		ProcessBlockPlacementQueue(Team, StaircaseModel)
		BlockTool:Destroy()
	end)

	local CollectionPart: Part = TeamService.GetBaseChild("Red", "CollectionPart") :: Part
	-- Spawn in Blocks
	local TeamZone = Zone.fromRegion(CollectionPart.CFrame, Vector3.new(15, 15, 15))
	TeamZone.playerEntered:Connect(
		function(player) -- Calculate how many the player needs to grab and how many are in the base
			StairService.HandleBlock(player)

			-- print(TeamZone)
			print("Now giving player a block to do something here with")
		end
	)
 
    
     
 --    print(CollectionPart)
    while true do 
        -- print("spawning something here")
         -- print("spawning in a brick ehre")
         local part = Instance.new("Part", CollectionPart)
         part.Size = Vector3.new(1, 1, 1)
         part.Parent = workspace
         part.Position = CollectionPart.Position + Vector3.new(0, 1, 0)
         task.wait(1) -- EDIT: Moved this out of the while loop condition to fit best practices
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
