local DataStoreService = game:GetService("DataStoreService")
--!strict

-- TODO
local DataService = {}

local DataTemplate = require(script.Template)

function DataService.GetPlayerData(Player: Player)
    return DataTemplate
end

return DataService