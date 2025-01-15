--!strict
local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init():Wait()

-- Services
local RoundService = Scrypt.GetService("RoundService")
local Utilities = Scrypt.GetModule("Utilities")

-- Function to send a packet to the client
local function sendPacketToClient(player: Player, message: string)
    local packetData = {
        Address = player,
        Reliable = true, -- Ensure the packet is delivered reliably
        Data = message,
    }:: Scrypt.ServerPacketData

    -- Use SendPacket to send the packet to the specific player

    Scrypt.ServerNetwork.SendPacketToClient("WelcomeMessage", packetData)
    print("sent the packet here")
end

-- Handles all functions for when the character gets added
local function CharacterAdded(Character: Model, Player: Player)
	-- print("Character added")
end

local function OnPlayerAdded(Player: Player)
    -- Handle character addeds

    while task.wait(1) do 


    end
    

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

    -- Send a welcome message to the player
    Scrypt.ServerNetwork.SendPacketToClient("WelcomeMessage", {
        Address = Player,
        Reliable = true,
        Data = "NewPacket"
    })
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
    repeat task.wait() until #Scrypt.Services.Players:GetPlayers() > 0
    -- RoundController:Init()
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