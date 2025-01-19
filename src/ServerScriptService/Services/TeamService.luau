--!strict

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
local Teams = game:GetService("Teams")
Scrypt.Init()

local TeamService = {}
--[=[
    @class TeamService
    @server
]=]

--[=[
    @type TeamParams {Name: string, TeamColor: BrickColor}
    @within TeamService
]=]
type TeamParams = {
    Name: string,
    TeamColor: BrickColor,
}

-- Create teams base function
local function CreateTeam(Name: string, TeamColor: BrickColor, Teams: Instance): Team
    local Team = Teams:FindFirstChild(Name):: Team or Instance.new("Team", Teams)
    Team.Name = Name
    Team.TeamColor = TeamColor

    return Team
end

local function AssignTeam(Player: Player, Team: Team)
    Player.Team = Team
end

--[=[
    @param Player Player
    @param Team Team
    @within TeamService
    Switches the player to the specified team.
]=]
function TeamService.SwitchTeams(Player: Player, Team: Team)
    -- TODO Make sure to check if the progress of the stairs is not over 90 percent
    AssignTeam(Player, Team)
end

-- Get the team with the lowest amount of players
local function GetLowestTeam(...: Team): Team?
    local LowestTeam
    local LowestCount = math.huge

    for _, team in ipairs({...}) do
        local PlayerCount = #team:GetPlayers()
        if PlayerCount < LowestCount then
            LowestCount = PlayerCount
            LowestTeam = team
        elseif PlayerCount == LowestCount then
            local Seed = os.clock()*10000
            local RandomSet = Random.new(Seed)
            local Num = RandomSet:NextInteger(1, 2)
            if Num == 1 then
                LowestCount = PlayerCount
                LowestTeam = team
            end
        end
    end

    if not LowestTeam then
        warn("No team found.")
        return nil
    end

    return LowestTeam
end

--[=[
    @param TeamsLocation Instance
    @param ... TeamParams
    @within TeamService
    Creates teams with the specified parameters.
]=]
function TeamService.CreateTeams(TeamsLocation: Instance, ...: TeamParams): ...Team
    local TeamData = {...}
    local Teams = {}

    for _, data in ipairs(TeamData) do
        local Team = CreateTeam(data.Name, data.TeamColor, TeamsLocation)
        table.insert(Teams, Team)
    end

    return unpack(Teams):: Team
end

--[=[
    @param TeamName string
    @param ChildName string?
    @within TeamService
    @return Folder
    Gets a base child from the specified team.
]=]
function TeamService.GetBaseChild(TeamName: string, ChildName: string?): Folder
    assert(TeamName, "Team name not provided.")
    assert(ChildName, "Child name not provided.")

    local MainFolder = workspace:FindFirstChild("Bases"):: Folder
    local TeamFolder = MainFolder:FindFirstChild(TeamName):: Folder
    assert(TeamFolder, "Team folder not found in workspace.")

    local Child = TeamFolder:FindFirstChild(ChildName)
    assert(Child, "Child not found in team folder.")
    return Child:: Folder
end

--[=[
    @param ...
    @within TeamService
    Fills teams evenly with players.
]=]
function TeamService.FillTeamsEvenly(...: Team)
    local Seed = os.clock()*10000
    local RandomSet = Random.new(Seed)
    local Teams = {...}
    local PlayingPlayers = Scrypt.Services.Players:GetPlayers()

    -- Shuffle playing players array
    for i = #PlayingPlayers, 2, -1 do
        local j = RandomSet:NextInteger(1, i)
        PlayingPlayers[i], PlayingPlayers[j] = PlayingPlayers[j], PlayingPlayers[i]
    end
    
    for _, player in ipairs(PlayingPlayers) do
        local TeamToAssign = GetLowestTeam(...)
        if TeamToAssign then
            AssignTeam(player, TeamToAssign)
            continue
        end

        local RandomTeam = Teams[RandomSet:NextInteger(1, #Teams)]
        print(RandomTeam);
        AssignTeam(player, RandomTeam)
    end

    -- TODO make it so that teams are filled evenly instead of just randomly
end

return TeamService