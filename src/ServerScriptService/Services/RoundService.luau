--!strict
-- File: ServerScriptService/Modules/GameModule.luau

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

local RoundService = {}

local Players = Scrypt.Services.Players
local TeamService = Scrypt.GetService("TeamService")

-- 1. Intermission Function
function RoundService.Intermission(Duration: number)
    print("Intermission started. Waiting for " .. tostring(Duration) .. " seconds...")

    for i = Duration, 1, -1 do
        print(tostring(i) .. " seconds remaining...")
        task.wait(1)
    end

    print("Intermission ended.")
end

-- 3. Teleport to Spawn Points Function
function RoundService.TeleportPlayers()
    local TeamFolder = workspace:FindFirstChild("Teams"):: Folder
    assert(TeamFolder, "Teams folder not found in workspace.")

    local RedSpawn: SpawnLocation = TeamFolder:FindFirstChildWhichIsA("SpawnLocation"):: SpawnLocation
    local BlueSpawn: SpawnLocation = TeamFolder:FindFirstChildWhichIsA("SpawnLocation"):: SpawnLocation

    assert(RedSpawn, "Red spawn point not found.")
    assert(BlueSpawn, "Blue spawn point not found.")

    local players = Players:GetPlayers()
    for _, player in ipairs(players) do
        if player.Team.Name == "Red" then
            player.Character:PivotTo(RedSpawn.CFrame)
        elseif player.Team.Name == "Blue" then
            local Offset = Vector3.new(0, 3, 0)
            local CFrame = BlueSpawn.CFrame
            player.Character:PivotTo(BlueSpawn.CFrame)
        end
    end
end

return RoundService