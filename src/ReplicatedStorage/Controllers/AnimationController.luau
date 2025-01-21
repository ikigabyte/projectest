

local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

local CurrentItems = {}

--Private functions
local AnimationTypes = {

    Explosive = {
        TweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
    }
    
}
local AnimationController = {}



--[=[
    @param Element Instance
    @within PlayerService
    @return Tween
    Setups the element with the respective Tween
]=]

function AnimationController.SetupAnimation(Element : Instance, AnimationType : string, Props : table)
    




    -- Return just the tween functionality
end



return AnimationController