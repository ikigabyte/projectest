--!strict
-- File: ServerScriptService/Modules/RoundService.luau

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

local RoundService = {}

local Players = Scrypt.Services.Players
local TeamService = Scrypt.GetService("TeamService")
local PlayerService = Scrypt.GetService("PlayerService")

type RulesType = {
    IntermissionTime: number,
    SpawnTime: number,
    RoundTime: number,
    PlayersNeeded: number,
}

local RULES : RulesType = {
    IntermissionTime = 2,
    SpawnTime = 5,
    RoundTime = 300,
    PlayersNeeded = 1,
}

-- Renamed and fixed type
local RoundThread: thread
local IntermissionConnection = Scrypt.CreateSignal("IntermissionEnded")

-- 1. Intermission Function
function RoundService.Intermission(Duration: number)
    assert(Duration, "Duration not provided.") -- Added assert to check if Duration is provided

    -- EDIT: Now uses string interpolation to print the duration
    print(`Intermission started. Waiting for {tostring(Duration)} seconds...`)

    -- EDIT: Moved loop into a task.defer to avoid blocking the main thread
    task.defer(function()
        for i = Duration, 1, -1 do
            print(tostring(i) .. " seconds remaining...")
            task.wait(1)
        end
    end)

    IntermissionConnection:Fire()
    print("Intermission ended.")
end

function RoundService.StartRound()
	print("Round started.")

    task.wait(RULES.RoundTime)

    -- EDIT: changed from task.defer to task.spawn. Also changed variable name to RoundThread since spawn and defer return threads not connections
	RoundThread = task.defer(function()
		print("Round ended.")
	end)
end

-- 3. Teleport to Spawn Points Function
function RoundService.TeleportPlayers(TeamsLocation: Instance)
    -- EDIT: Made the teams folder user-provided to avoid hardcoding the teams folder location
    assert(TeamsLocation, "Teams folder not provided.")

    -- EDIT: Removed Players and Offset variables since they can be used directly in the loop

    -- EDIT: Made this loop more general. Instead of using hardcoded team names, it now uses the team folder provided by the user and trys to teleport players based on their assigned team
    for _, player in ipairs(Players:GetPlayers()) do
        local playerTeam = player.Team
        if not playerTeam then
            warn("Player " .. player.Name .. " does not have a team assigned.")
            continue
        end

        local teamLocation = TeamsLocation:FindFirstChild(playerTeam.Name):: Instance
        local teamSpawn = teamLocation:FindFirstChildWhichIsA("SpawnLocation"):: SpawnLocation
        local character = player.Character

        if not teamSpawn then
            warn("Spawn location not found for team: " .. playerTeam.Name)
            continue
        end

        if not character then
            warn("Could not find character for player: " .. player.Name)
            continue
        end
        
        character:PivotTo(teamSpawn.CFrame*CFrame.new(0, 3, 0))
    end
end

-- MAYBE: Will move this to the game manager and instead of using a loop, use the Event driven paradigm to handle the game state 
function RoundService:Init()
    while true do 
        if #Players:GetPlayers() >= RULES.PlayersNeeded then
            RoundService.Intermission(RULES.IntermissionTime)
            TeamService.FillTeamsEvenly(TeamService.CreateTeams(game:GetService("Teams"), {
                Name = "Red",
                TeamColor = BrickColor.Red(),
            }, {
                Name = "Blue",
                TeamColor = BrickColor.Blue(),
            }))

            RoundService.TeleportPlayers(workspace:FindFirstChild("Bases"):: Instance)
            RoundService.StartRound()
            continue -- EDIT: Removed else in favor of continue        
        end

        -- EDIT: This used to be in an else statement, but I moved it out of the else statement to keep indentations minimal
        -- warn("not enough players")
        task.wait(2)
        
        -- EDIT: Fixed function usage (although I should change the usage to fit what you had before since it's more consistent) 
        Scrypt.ServerNetwork.SendPacketToAllClients("PlayersNeeded", "Not enough players to start the game.", true)
    end
end

return RoundService