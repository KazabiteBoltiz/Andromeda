local RepS = game:GetService('ReplicatedStorage')
local Packages = RepS.Packages
local Trove = require(Packages.Trove)

local ts = game:GetService('TweenService')

local lastSpawned = os.clock()

local trailsInfo = TweenInfo.new(
	.5,
	Enum.EasingStyle.Sine,
	Enum.EasingDirection.Out
)

local function smokeBlock(HrpCF)
	local newCube = Instance.new('Part')
	newCube.Size = Vector3.one * 1.3
	newCube.Transparency = 0
	newCube.Color = Color3.new(1,1,1)
	newCube.Material = Enum.Material.SmoothPlastic
	newCube.Anchored = true
	newCube.CanCollide = false
	newCube.CanQuery = false
	newCube.CFrame = HrpCF 
		* CFrame.new(math.random(-50,50)/100,-2.3,1)
		* CFrame.Angles(
			math.rad(math.random(-180,180)),
			math.rad(math.random(-180,180)),
			math.rad(math.random(-180,180))
		)
	newCube.Parent = workspace.Terrain

	local trailTween = ts:Create(
		newCube, 
		trailsInfo, 
		{
			CFrame = newCube.CFrame 
				* CFrame.new(0,0,1)
				* CFrame.new(0,math.random(100,150)/100,0),
			Size = Vector3.one * .2,
			Transparency = .6
		}
	)
	trailTween:Play()
	trailTween.Completed:Connect(function()
		newCube:Destroy()
	end)
end

local function walkTrails(myTrove, Hrp)
	local lastPosition = Hrp.Position * Vector3.new(1,0,1)
	
	myTrove:Connect(game:GetService('RunService').Stepped, function()
		local nowXZ = Hrp.Position * Vector3.new(1,0,1)
		local distance = (lastPosition - nowXZ).Magnitude
		
		if os.clock() - lastSpawned > .2 and distance > 5 then
			
			lastPosition = nowXZ
			lastSpawned = os.clock()

			for i = 1, math.random(1,3) do
				smokeBlock(Hrp.CFrame)
			end
		end
	end)
end

local Troves = {}
local LastSteps = {}

local function OnCharacterAdded(Character)
	local Humanoid = Character.Humanoid
	
	local player = game.Players:GetPlayerFromCharacter(Character)
	if not Troves[player] then
		LastSteps[player] = 0
		Troves[player] = Trove.new()
	end
	
	Humanoid.AnimationPlayed:Connect(function(track)
		local isRun = track.Animation.AnimationId == 'rbxassetid://7896557091'

		if isRun then
			walkTrails(Troves[player], Character.HumanoidRootPart)
			
			Troves[player]:Connect(track.Stopped, function()
				Troves[player]:Clean()
			end)
		end
		
		local isJump = track.Animation.AnimationId == 'rbxassetid://7896562616'

		if isJump then
			for _ = 1, 5 do
				smokeBlock(Character.HumanoidRootPart.CFrame)
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