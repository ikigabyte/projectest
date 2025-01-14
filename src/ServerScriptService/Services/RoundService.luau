--!strict
-- File: ServerScriptService/Modules/RounService.luau

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

local RoundService = {}

local Players = Scrypt.Services.Players
local TeamService = Scrypt.GetService("TeamService")
local PlayerService = Scrypt.GetService("PlayerService")
local Zone = Scrypt.GetModule("Zone")

type RulesType = {
    IntermissionTime: number,
    SpawnTime: number,
    RoundTime: number,
    PlayersNeeded: number,
}

local Rules : RulesType = {
    IntermissionTime = 2,
    SpawnTime = 5,
    RoundTime = 300,
    PlayersNeeded = 1,
}

local BlueQueuePlacement = {}
local RedQueuePlacement = {}
local RedTeam = {
    RedQueuePlacement = {},
    StairPlacementZone = nil,
}

local RoundConnection : RBXScriptConnection
-- 1. Intermission Function
function RoundService.Intermission(Duration: number)
    print("Intermission started. Waiting for " .. tostring(Duration) .. " seconds...")
    for i = Duration, 1, -1 do
        print(tostring(i) .. " seconds remaining...")
        task.wait(1)
    end
    print("Intermission ended.")
end


function RoundService.HandleBlock(Player : Player)
    -- print("Handling block")
    local BlockTool = Instance.new("Tool")
    local Character = Player.Character
    assert(Character, "Character not found.")
    if Character:FindFirstChild("BlockTool") then
        return
        -- Character.BlockTool:Destroy()
    end
    BlockTool.Name = "BlockTool"
    BlockTool.Parent = Player.Character
    BlockTool.RequiresHandle = false;
    local Upgrade = PlayerService.GetBlockUpgrade(Player)
    BlockTool:SetAttribute("BlockUpgrade", Upgrade)
    local meshPart = Instance.new("Part")
    meshPart.Parent = BlockTool


    -- Put it 2 studs in front of the player 
    meshPart.CFrame = Character.PrimaryPart.CFrame * CFrame.new(0, 0, -2)
    meshPart.CanCollide = false
    meshPart.Size = Vector3.new(1.5, 1.5, 1.5)
    local wc  = Instance.new("WeldConstraint")
    wc.Parent = meshPart
    wc.Part0 = meshPart
    wc.Part1 = Character.PrimaryPart

end

function RoundService.StartSpawning()
   local CollectionPart : Part =  TeamService.GetBaseChild("Red", "CollectionPart"):: Part
   -- Spawn in Blocks
    local TeamZone = Zone.fromRegion(CollectionPart.CFrame, Vector3.new(15,15,15))
    TeamZone.playerEntered:Connect(function(player)
        RoundService.HandleBlock(player)
        -- print(TeamZone)
        print("Now giving player a block to do something here with")
    end)

    
--    print(CollectionPart)
   while task.wait(1) do 
        -- print("spawning in a brick ehre")
        local part = Instance.new("Part", CollectionPart)
        part.Size = Vector3.new(1, 1, 1)
        part.Parent = workspace
        part.Position = CollectionPart.Position + Vector3.new(0, 1, 0)
        
   end
end

local isProcessing = false -- Variable to track if the queue is already being processed

function ProcessBlockPlacementQueue(QueueToProcess: string)
    -- Determine which queue to process
    local Queue = (QueueToProcess == "Blue") and BlueQueuePlacement or RedQueuePlacement
    -- If the queue is already being processed, return early
    if isProcessing then
        return
    end

    isProcessing = true -- Mark the queue as being processed

    task.spawn(function()
        while #Queue > 0 do
            print("Processing the respective queue here")
            -- Take the first request from the queue
            table.remove(Queue, 1)
            -- print(Queue
            local StairCase = workspace.StaircaseModel
            local children = StairCase:GetChildren()
            table.sort(children, function(a, b)
                local numA = tonumber(a.Name) or 0 -- Convert to number, default to 0 if not a valid number
                local numB = tonumber(b.Name) or 0
                return numA < numB
            end)
            
            for i, child in pairs(children) do
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

function RoundService.HandleStaircase()
    -- local Zone = Zone.fromRegion(workspace:FindFirstChild("StaircaseModel"), Vector3.new(15, 15, 15))
    local StaircaseModel = workspace:FindFirstChild("StaircaseModel") :: Model
    local ZoneCreator = Zone.fromRegion(StaircaseModel["1"].CFrame, Vector3.new(15,15,15))
    print("staircase created")
    ZoneCreator.playerEntered:Connect(function(Player : Player)
        
        local Team = Player.Team   
        
        print("Player entered the zone, now placing something here")
        local BlockTool = Player.Character:FindFirstChild("BlockTool")
        if BlockTool then
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
        end
    end)
    

end

function RoundService.StartRound()
	print("Round started.")
    task.spawn(function()
        RoundService.StartSpawning()
    end)
    RoundService.HandleStaircase()
    print("handling staircase")
    task.wait(Rules.RoundTime)
	RoundConnection = task.spawn(function()
		print("Round ended.")
	end)
end
-- 3. Teleport to Spawn Points Function
function RoundService.TeleportPlayers()
    local TeamFolder = workspace:FindFirstChild("Bases"):: Folder
    assert(TeamFolder, "Teams folder not found in workspace.")

    local RedSpawn: SpawnLocation = TeamFolder["Red"]:FindFirstChildWhichIsA("SpawnLocation"):: SpawnLocation
    local BlueSpawn: SpawnLocation = TeamFolder["Blue"]:FindFirstChildWhichIsA("SpawnLocation"):: SpawnLocation

    assert(RedSpawn, "Red spawn point not found.")
    assert(BlueSpawn, "Blue spawn point not found.")
    local Offset = Vector3.new(0, 3, 0)
    local players = Players:GetPlayers()
    for _, player in ipairs(players) do
        if player.Team.Name == "Red" then
            player.Character:PivotTo(RedSpawn.CFrame * CFrame.new(Offset))
        elseif player.Team.Name == "Blue" then
            player.Character:PivotTo(BlueSpawn.CFrame * CFrame.new(Offset))
        end
    end
end



function RoundService:Init()
    while true do 
        if #Players:GetPlayers() >= Rules.PlayersNeeded then
            RoundService.Intermission(Rules.IntermissionTime)
            TeamService.FillTeamsEvenly(TeamService.CreateTeams(game:GetService("Teams"), {
                Name = "Red",
                TeamColor = BrickColor.Red(),
            }, {
                Name = "Blue",
                TeamColor = BrickColor.Blue(),
            }))
            RoundService.TeleportPlayers()
            RoundService.StartRound()
            
        else
            -- warn("not enough players")
            task.wait(2)
            Scrypt.ServerNetwork.SendPacketToAllClients("PlayersNeeded", {
                Reliable = true,
                Data = "Not enough players to start the game."
            })
        end

    end

    

end



return RoundService