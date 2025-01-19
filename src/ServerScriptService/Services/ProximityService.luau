local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

local ProximityService = {}

function ProximityService.ListenForProximity(ActionName: string, Callback: (Player) -> nil)
    local Connection: RBXScriptConnection
    Connection = Scrypt.Services.ProximityPromptService.PromptTriggered:Connect(function(Prompt: ProximityPrompt, Player: Player)
        if Prompt.ActionText == ActionName then
            Callback(Player)
        end
    end)

    return Connection
end

return ProximityService