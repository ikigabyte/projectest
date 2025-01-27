--!strict
-- File: ServerScriptService/Modules/RoundService.luau

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

local RoundService = {}
--[=[
    @class RoundService
    @server
]=]

local Players = Scrypt.Services.Players
local TeamService = Scrypt.GetService("TeamService")
local PlayerService = Scrypt.GetService("PlayerService")
local StairService = Scrypt.GetService("StairService")
local GameConfig = Scrypt.GetModule("GameConfig")

--[=[
    @type RulesType {
        IntermissionTime: number,
        SpawnTime: number,
        RoundTime: number,
        PlayersNeeded: number,
    }
    @within RoundService
]=]
type RulesType = {
    IntermissionTime: number,
    SpawnTime: number,
    RoundTime: number,
    PlayersNeeded: number,
}

-- Changes all the rules to be part of the config
local RULES: RulesType = {
    IntermissionTime = GameConfig.Intermission,
    SpawnTime = GameConfig.SpawnTime,
    RoundTime = GameConfig.RoundTime,
    PlayersNeeded = GameConfig.SpawnTime,
}

local IntermissionStartedEvent = Scrypt.CreateSignal("IntermissionStarted") 
local IntermissionEndedEvent = Scrypt.CreateSignal("IntermissionEnded")
local RoundStartedEvent = Scrypt.CreateSignal("RoundStarted")
local RoundEndedEvent = Scrypt.CreateSignal("RoundEndedConnection")

local function TeleportPlayer(player: Player, TeamsLocation: Instance)
    local playerTeam = player.Team
    if not playerTeam then
        warn("Player " .. player.Name .. " does not have a team assigned.")
        return
    end

    local teamLocation = TeamsLocation:FindFirstChild(playerTeam.Name):: Instance
    local teamSpawn = teamLocation:FindFirstChildWhichIsA("SpawnLocation"):: SpawnLocation
    local character = player.Character

    if not teamSpawn then
        warn("Spawn location not found for team: " .. playerTeam.Name)
        return
    end

    if not character then
        warn("Could not find character for player: " .. player.Name)
        return
    end
    
    character:PivotTo(teamSpawn.CFrame*CFrame.new(0, 3, 0))
end

--[=[
    @param Duration number
    @within RoundService
    Starts an intermission for the provided duration.
]=]
function RoundService.Intermission(Duration: number)
    assert(Duration, "Duration not provided.")
    print(`Intermission started. Waiting for {tostring(Duration)} seconds...`)

    IntermissionStartedEvent:Fire()
    for i = Duration, 1, -1 do
        Scrypt.ServerNetwork.SendPacketToAllClients("UpdateRoundTime",i, true)

        task.wait(1)
    end

    IntermissionEndedEvent:Fire()
end

--[=[
    @within RoundService
    Starts a round.
]=]
function RoundService.StartRound()
    RoundStartedEvent:Fire()
    task.wait(RULES.RoundTime)
    
    RoundEndedEvent:Fire()
end

--[=[
    @param TeamsLocation Instance
    @within RoundService
    Teleports all players to their respective teams.
]=]
function RoundService.TeleportPlayers(TeamsLocation: Instance)
    assert(TeamsLocation, "Teams folder not provided.")

    for _, player in ipairs(Players:GetPlayers()) do
        TeleportPlayer(player, TeamsLocation)
    end
end

local function LoopRounds()
    while true do 
        if #Players:GetPlayers() >= RULES.PlayersNeeded then
            RoundService.Intermission(RULES.IntermissionTime)
            TeamService.FillTeamsEvenly(unpack(game:GetService("Teams"):GetChildren()))
            RoundService.TeleportPlayers(workspace:FindFirstChild("Bases"):: Instance)
            RoundService.StartRound()
            continue   
        end

        task.wait(2)
        
        Scrypt.ServerNetwork.SendPacketToAllClients("PlayersNeeded", "Not enough players to start the game.", true)
    end
end

--[=[
    @within RoundService
    Initializes the RoundService.
]=]
function RoundService.Init()
    task.defer(LoopRounds)
    return
end

return RoundService