

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

local Zone = Scrypt.GetModule("Zone")
local CollectionService : CollectionService = Scrypt.Services.CollectionService
local UIController = Scrypt.GetController("UIController")
local ZoneController = {}


-- Function to setup the zone based on the hitbox or the region
local function SetupZone(model: Model, hasHitbox: boolean)
    -- Check if the model exists
    assert(model, "Model not provided to SetupZone function")
    -- Determine the type of zone setup
    local newZone
    if hasHitbox then
        local hitbox : Part = model:FindFirstChild("Hitbox")
        local hitboxSize = hitbox.Size
        assert(hitbox, "Hitbox not found in model: " .. model.Name)
     
        newZone = Zone.fromRegion(hitbox.CFrame , hitboxSize)  
    else
        return -- temporary thing here
        -- newZone = Zone.fromPart(hitbox)  -- Assuming the zone library supports fromPart
    end



    -- Ensure the zone was created successfully
    assert(newZone, "Failed to create zone for model: " .. model.Name)
    -- Return the entered and exited events properly

    print("Zone has been setup correctly")
    return newZone.localPlayerEntered, newZone.localPlayerExited
end

function ZoneController.InitateAllZones()
    
    local MarketShopModel : Model = workspace:WaitForChild("BigMarket")
    MarketShopModel:WaitForChild("Hitbox") -- Needed for Streaming
    local PlayerEntered, PlayerExited = SetupZone(MarketShopModel, true)
    print("test has been succesfully setup")
    -- print(PlayerEntered)
    PlayerEntered:Connect(function()
        
        -- UIController.TurnOnRespectiveGui("Shop") -- We need to preload this it shows a jittery lag for some reaosn
        Scrypt.GUI.Shop.Gui.Enabled = true
        
        -- print(Scrypt.GUI.GameGui.Enabled)
        print("you entered the zone")
        
        -- UIController.TurnOffAllFrames()
    end)
    PlayerExited:Connect(function()
        Scrypt.GUI.Shop.Gui.Enabled = false
        -- Scrypt.GUI.MainGui.BlockPacks.Visible = true
        -- Scrypt.GUI.GameGui.Enabled = false
        -- print(Scrypt.GUI.GameGui.Enabled)
        print("player has left here")
    -- print("this has worked so far here")
        -- UIController.TurnOffAllFrames()
    end)
    


end



return ZoneController