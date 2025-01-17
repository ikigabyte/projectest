--!strict
local Scrypt = require(game:GetService("ReplicatedStorage").Scrypt)
Scrypt.Init()

local Utilities = Scrypt.GetModule("Utilities")
local SoundService: SoundService = Scrypt.Services.SoundService

local AudioController = {}

-- Gets the specified sound in the sounds folder
local function GetSound(SoundName: string, Parent: Instance?): Sound?
	local Sounds = Utilities.SafeFindObject(SoundService, "GameEffects"):: SoundGroup
	if not Sounds then return nil end

	-- Find sound in sounds folder
	local NewSound: Sound
	for index, sound in ipairs(Sounds:GetDescendants()) do
		if not (tostring(sound) == SoundName) then continue end

		NewSound = sound:Clone():: Sound
		NewSound.Parent = SoundService.SoundsPlaying

		break
	end

	return NewSound
end

-- Creates a sound part at the specified position
local function CreateSoundPart(Position: Vector3): Part
	local NewPart = Instance.new("Part")
	NewPart.Position = Position
	NewPart.Transparency = 1
	NewPart.Anchored = true
	NewPart.CanCollide = false
	NewPart.CanQuery = false
	NewPart.CanTouch = false
	NewPart.Name = "SoundPart"
	NewPart.Parent = workspace
	
	return NewPart
end

-- Loops a sound
function AudioController.LoopSound(SoundName: string, Volume: number?): Sound | boolean
	assert(SoundName and typeof(SoundName) == "string", `SoundName is not valid. Expected string got: {typeof(SoundName)}`)
	
	local PlayingSounds = SoundService.SoundsPlaying
	if PlayingSounds:FindFirstChild(SoundName) then return false end
	
	local Sound = GetSound(SoundName)
	if not Sound then return false end

	-- Default values
	local SoundVolume: number = Volume or 0.5
	Sound.Volume = SoundVolume
	Sound.TimePosition = 0

	-- Handle playing the module
	Sound.Looped = true
	Sound.Playing = true
	
	return Sound
end
local function GetRandomPitch(variationAmount: number)
    -- Ensure variationAmount is valid
    variationAmount = math.clamp(variationAmount, 0, 1) -- Prevent it from exceeding valid bounds
    
    -- Calculate range dynamically
    local minPitch = 1 - (0.3 * variationAmount) -- Minimum pitch (0.7 when variationAmount is 1)
    local maxPitch = 1 + (0.3 * variationAmount) -- Maximum pitch (1.3 when variationAmount is 1)
    
    -- Generate a random pitch within the range
    local randomPitch = math.random(minPitch * 100, maxPitch * 100) / 100
    return randomPitch
end
-- Plays a Sound X times
function AudioController.PlaySound(SoundName: string, Plays: number?, Cooldown: number?, Volume: number?, Position: Vector3?, PitchVariation): boolean
	assert(SoundName and typeof(SoundName) == "string", `SoundName is not valid. Expected string got: {typeof(SoundName)}`)
	local Sound = GetSound(SoundName)
	local SoundPart
	
	if not Sound then return false end
	
	--Default values
	local SoundPlays: number = Plays or 1
	local SoundVolume: number = Volume or 0.5
	if Cooldown == 0 then Cooldown = Sound.TimeLength end
	-- Cooldown = Cooldown or Sound.TimeLength
	Sound.Volume = SoundVolume
	Sound.TimePosition = 0
	
	if Position then SoundPart = CreateSoundPart(Position); Sound.Parent = SoundPart end
	-- Handle playing the module
	if PitchVariation ~= nil then
		local PitchEffect = Instance.new("PitchShiftSoundEffect")
		
		PitchEffect.Octave = GetRandomPitch(PitchVariation)
		-- print(GetRandomPitch(PitchVariation))
		PitchEffect.Enabled = true
	end

	task.defer(function()
		for count = 1, SoundPlays, 1 do
			-- task.wait(math.random(0,0.15)) 
			Sound:Play()
			task.wait(Cooldown)
		end
		Scrypt.Services.Debris:AddItem(Sound, Cooldown) -- Changed from Cooldown to TimeLength instead
		if SoundPart then Scrypt.Services.Debris:AddItem(SoundPart, Cooldown) end
	end)
	
	return true
end

-- Stops a playing sound from playing
function AudioController.StopSound(SoundName: string): boolean
	assert(SoundName and typeof(SoundName) == "string", `SoundName is not valid. Expected string got: {typeof(SoundName)}`)
	
	local PlayingSounds = SoundService.SoundsPlaying:GetChildren()
	
	for index, sound in ipairs(PlayingSounds) do
		if not (SoundName == tostring(sound)) then continue end
		
		sound:Destroy()
		return true
	end
	
	warn("Could not stop sound")
	return false
end

return AudioController