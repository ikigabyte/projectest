
local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init():Wait()

-- Services
local RoundService = Scrypt.GetService("RoundService")
local Teams = game:GetService("Teams")
local Utilities = Scrypt.GetModule("Utilities")
local TeamService = Scrypt.GetService("TeamService")
local RoundEvents

-- Handles all functions for when the character gets added
local function CharacterAdded(Character: Model, Player: Player)
	-- print("Character added")
end

local function OnPlayerAdded(Player: Player)
    -- Handle character addeds



    -- while task.wait(1) do 


    -- end
    
	CharacterAdded(Player.Character or Player.CharacterAdded:Wait(), Player)
	Player.CharacterAdded:Connect(function(Character)
		CharacterAdded(Character, Player)
	end)
	
    -- Handle memory leak
    Player.CharacterRemoving:Connect(function(Character: Model)
        repeat
            local Success = pcall(function()
                task.defer(Character.Destroy, Character)
            end)
        until Success
    end)
end


-- Handle Player leaving
local function OnPlayerRemoving(Player: Player)
	-- Erase player from server
	
	-- Handle memory leak
	repeat
		local Success = pcall(function()
			task.defer(Player.Destroy, Player)
		end)
	until Success
end

-- Example usage: Send a welcome message to players when they join
Utilities.SafePlayerAdded(OnPlayerAdded)
Scrypt.Services.Players.PlayerRemoving:Connect(OnPlayerRemoving)







-- Initializers
task.spawn(function()
    local Red, Blue, Intermission = TeamService.CreateTeams(Teams, {
        Name = "Red",
        TeamColor = BrickColor.Red(),
    }, {
        Name = "Blue",
        TeamColor = BrickColor.Blue(),
    })
    repeat task.wait() until #Scrypt.Services.Players:GetPlayers() > 0
    RoundEvents = RoundService.Init()
    RoundEvents.IntermissionStarted:Connect(function()
        for i, v in ipairs(Scrypt.Services.Players:GetPlayers()) do
            v.Team = nil
        end
    end)
end)

-- Secondary setup
-- task.defer(function()
	
-- end)

-- Next Heartbeat setup
-- task.delay(0, function()
	
-- end)

-- Loops
--while true do
--	task.wait(1)
--end