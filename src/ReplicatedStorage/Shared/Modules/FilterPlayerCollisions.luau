--!strict

local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

-- Create collision group for players if it doesn't exist
local PLAYER_GROUP_NAME = "Players"
local success, _ = pcall(function()
    PhysicsService:RegisterCollisionGroup(PLAYER_GROUP_NAME)
    -- Players shouldn't collide with other players
    PhysicsService:CollisionGroupSetCollidable(PLAYER_GROUP_NAME, PLAYER_GROUP_NAME, false)
end)

-- Filters collisions so other players are ignored
local function FilterCollisions(Character: Model)
    if not Character then return end
    
    -- Function to set collision group for a part
    local function setCollisionGroup(part: BasePart)
        if part:IsA("BasePart") then
            part.CollisionGroup = PLAYER_GROUP_NAME
        end
    end
    
    -- Set collision group for all existing parts
    for _, part in Character:GetDescendants() do
        setCollisionGroup(part)
    end
    
    -- Connect to DescendantAdded to handle new parts
    Character.DescendantAdded:Connect(setCollisionGroup)
end

return FilterCollisions