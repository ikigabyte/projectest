--!strict
local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init():Wait()


-- task.wait(3)

Scrypt.ClientNetwork.ListenForPacket("WelcomeMessage", function(packetData)
	print("Received welcome message: " .. packetData.Data)
end)