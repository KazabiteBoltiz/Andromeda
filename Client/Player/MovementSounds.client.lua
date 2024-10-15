local RepS = game:GetService('ReplicatedStorage')
local Packages = RepS.Packages
local Trove = require(Packages.Trove)

local Components = RepS.Components
local CamComponent = require(Components.Camera)

local SoundIDs = {
	Footsteps = 5946030214,
	Land = 7534134750,
	Jump = 8918679081,
	Roll = 1161221108
}

local Troves = {}

local function ClearSounds(inst)
	for _, sound in inst:GetChildren() do
		if sound:IsA('Sound') then
			sound:Destroy()
		end
	end
end

local function PlaySound(id, parent, volume)

	if not parent:FindFirstChild(id) then
		local sound = Instance.new('Sound')
		sound.Volume = volume * 2
		sound.SoundId = id
		sound.Name = id
		sound.RollOffMinDistance = 30
		sound.Parent = parent
		sound:Play()
	else
		local sound = parent:FindFirstChild(id)
		sound:Play()
	end
end

local function OnCharacterAdded(Character)
	local player = game.Players:GetPlayerFromCharacter(Character)
	if Troves[player] then
		Troves[player]:Clean()
	else
		Troves[player] = Trove.new()
	end
	
	local Root = Character:WaitForChild('HumanoidRootPart')
	Troves[player]:Connect(Root.ChildAdded, function()
		ClearSounds(Root)
	end)
	ClearSounds(Root)
	
	local Humanoid = Character:WaitForChild('Humanoid')
	
	local lastFootstep = os.clock()
	Troves[player]:Connect(Humanoid.AnimationPlayed, function(track)
		local isRun = track.Animation.AnimationId == 'rbxassetid://7896557091'
		
		if isRun then
			local stepSignal = track:GetMarkerReachedSignal('Footstep')
			local stepConn = stepSignal:Connect(function()
				if os.clock() - lastFootstep < .1 then return end
				lastFootstep = os.clock()
				
				PlaySound(
					'rbxassetid://'..SoundIDs.Footsteps,
					Character.Torso,
					.07
				)
				
				if player == game.Players.LocalPlayer then
					local MyCam = CamComponent:GetAll()[1]
					MyCam:Shake('Bump', 35,-.5,.1,30)
				end
			end)

			Troves[player]:Connect(track.Stopped, function()
				stepConn:Disconnect()
			end)

			Troves[player]:Add(stepConn, 'Disconnect')
		end 
		
		local isLand = track.Animation.AnimationId == 'rbxassetid://17769623788'
		
		if isLand then
			PlaySound(
				'rbxassetid://'..SoundIDs.Land,
				Character.Torso,
				.05
			)
			
			if player == game.Players.LocalPlayer then
				local MyCam = CamComponent:GetAll()[1]
				MyCam:Shake('Bump', 30,-1.5,.1,15)
			end
		end
		
		local isJump = track.Animation.AnimationId == 'rbxassetid://7896562616'
		
		if isJump then
			PlaySound(
				'rbxassetid://'..SoundIDs.Jump,
				Character.Torso,
				.15
			)
			
			if player == game.Players.LocalPlayer then
				local MyCam = CamComponent:GetAll()[1]
				MyCam:Shake('Bump', 30,-3,.1,15)
			end
		end
		
		local isRoll = track.Animation.AnimationId == 'rbxassetid://16747851690'
		
		if isRoll then
			PlaySound(
				'rbxassetid://'..SoundIDs.Roll,
				Character.Torso,
				.15
			)
			
			if player == game.Players.LocalPlayer then
				local MyCam = CamComponent:GetAll()[1]
				MyCam:Shake('Bump', 30,-1.5,.1,15)
			end
		end
	end)
	
end

local function OnPlayerAdded(player)
	player.CharacterAdded:Connect(OnCharacterAdded)
end

game.Players.PlayerAdded:Connect(OnPlayerAdded)

for _, existingPlayer in game.Players:GetChildren() do
	OnPlayerAdded(existingPlayer)
	
	if existingPlayer.Character then
		OnCharacterAdded(existingPlayer.Character)
	end
end