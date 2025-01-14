-- File: ServerScriptService/Modules/GameModule.luau
local GameModule = {}

local Teams = game:GetService("Teams")
local Players = game:GetService("Players")

-- Red and Blue Teams Setup
-- 1. Intermission Function

function GameModule.CreateTeams() : Team
    local RedTeam = Teams:FindFirstChild("Red") or Instance.new("Team", Teams)
    RedTeam.Name = "Red"
    RedTeam.TeamColor = BrickColor.new("Bright red")
    
    local BlueTeam = Teams:FindFirstChild("Blue") or Instance.new("Team", Teams)
    BlueTeam.Name = "Blue"
    BlueTeam.TeamColor = BrickColor.new("Bright blue")
    return RedTeam, BlueTeam
end
function GameModule.Intermission(duration)
    print("Intermission started. Waiting for " .. duration .. " seconds...")
    for i = duration, 1, -1 do
        print(i .. " seconds remaining...")
        wait(1)
    end
    print("Intermission ended.")
end

-- 2. Team Assignment Function
function GameModule.AssignTeams(RedTeam, BlueTeam)
    local players = Players:GetPlayers()
    for _, player in ipairs(players) do
        if math.random(1, 2) == 1 then
            player.Team = RedTeam
            print(player.Name .. " has been assigned to Red Team.")
        else
            player.Team = BlueTeam
            print(player.Name .. " has been assigned to Blue Team.")
        end
    end
end

-- 3. Teleport to Spawn Points Function
function GameModule.TeleportPlayers()
    local TeamFolder = game.Workspace.Teams
    local RedSpawn :SpawnLocation= TeamFolder:FindFirstChild("SpawnLocation")
    local BlueSpawn :SpawnLocation= TeamFolder:FindFirstChild("SpawnLocation")

    local players = Players:GetPlayers()
    for _, player in ipairs(players) do
        if player.Team == "Red" then
            player.Character:SetPrimaryPartCFrame(RedSpawn.CFrame)
        elseif player.Team == "Blue" then
            local Offset = Vector3.new(0, 3, 0)
            local CFrame = BlueSpawn.CFrame
            player.Character:SetPrimaryPartCFrame(BlueSpawn.CFrame)
        end
    end
end

return GameModule