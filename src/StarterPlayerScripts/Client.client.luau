--!strict
local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init():Wait()


-- task.wait(3)

Scrypt.ClientNetwork.ListenForPacket("WelcomeMessage", true, function(packetData)
	print("Received welcome message: " .. tostring(packetData))
end)