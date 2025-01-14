--!strict
-- local DataStoreService = game:GetService("DataStoreService")
local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init():Wait()

-- local RoundController = require(Scrypt.Services.ServerScriptService.RoundController)

-- task.wait(2)


local ServerNetwork = Scrypt.ServerNetwork
-- Function to send a packet to the client
local function sendPacketToClient(player, message)
    local packetData = {
        Data = message,
        Reliable = true, -- Ensure the packet is delivered reliably
        Address = player
    }

    -- Use SendPacket to send the packet to the specific player

    ServerNetwork.SendPacketToPlayer(player.Name, packetData)
    print("sent the packet here")
end

-- Example usage: Send a welcome message to players when they join
game.Players.PlayerAdded:Connect(function(player)
    task.wait(2) -- Wait before sending the message
    sendPacketToClient(player, "Welcome to the game!")
end)