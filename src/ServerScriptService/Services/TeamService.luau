--!strict

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

local TeamService = {}

type TeamParams = {
    Name: string,
    TeamColor: BrickColor,
}

-- Create teams base function
local function CreateTeam(Name: string, TeamColor: BrickColor, Teams: Instance): Team
    local Team = Teams:FindFirstChild(Name):: Team or Instance.new("Team", Teams)
    Team.Name = Name
    Team.TeamColor = TeamColor
    print("Craeted the te")

    return Team
end

local function AssignTeam(Player: Player, Team: Team)
    Player.Team = Team
end

function TeamService.SwitchTeams(Player: Player, Team: Team)
    -- TODO Make sure to check if the progress of the stairs is not over 90 percent
    AssignTeam(Player, Team)
end

-- General function to create teams
function TeamService.CreateTeams(TeamsLocation: Instance, ...: TeamParams): ...Team
    local TeamData = {...}
    local Teams = {}

    for _, data in ipairs(TeamData) do
        local Team = CreateTeam(data.Name, data.TeamColor, TeamsLocation)
        table.insert(Teams, Team)
    end

    return unpack(Teams):: Team
end

function TeamService.GetBaseChild(TeamName: string, ChildName: string?): Folder
    local MainFolder = workspace:FindFirstChild("Bases"):: Folder
    local TeamFolder = MainFolder:FindFirstChild(TeamName):: Folder
    assert(TeamFolder, "Team folder not found in workspace.")

    if ChildName == nil then
        return TeamFolder
    end

    local Child = TeamFolder:FindFirstChild(ChildName)
    assert(Child, "Child not found in team folder.")
    return Child:: Folder
end

function TeamService.FillTeamsEvenly(...: Team)
    local Seed = os.time()
    local RandomSet = Random.new(Seed)
    local Teams = {...}
    local PlayingPlayers = Scrypt.Services.Players:GetPlayers()
    
    for _, player in ipairs(PlayingPlayers) do
        local RandomTeam = Teams[RandomSet:NextInteger(1, #Teams)]
        AssignTeam(player, RandomTeam)
    end

    -- TODO make it so that teams are filled evenly instead of just randomly
end

return TeamService