--!strict
local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init():Wait()

-- local DataStoreService = Scrypt.Services.DataStoreService
-- local RoundController = Scrypt.GetService("RoundService")

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

-- Example usage: Send a welcome message to players when they join
Scrypt.Services.Players.PlayerAdded:Connect(function(player: Player)
    task.delay(2, function()
        sendPacketToClient(player, "Welcome to the game!")
    end)
end)