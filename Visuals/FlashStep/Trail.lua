local RepS = game:GetService('ReplicatedStorage')
local Packages = RepS.Packages
local ReFX = require(Packages.ReFX)
local Tree = require(Packages.Tree)
local Trove = require(Packages.Trove)

local Modules = RepS.Modules
local GetPath = require(Modules.GetPath)

local GameData = RepS.GameData
local CoreData = require(GameData.CoreColors)

local RunS = game:GetService('RunService')

local Assets = RepS.Assets
local FlashStepAssets = Tree.Find(
    Assets,
    'FlashStep'
)

local Visuals = RepS.Visuals

local TrailEffect = ReFX.CreateEffect(
    GetPath(Visuals, script)
)

function TrailEffect:OnConstruct(Character, PlayerData)
    self.DestroyOnEnd = false
    self.MaxLifetime = .4

    self.Character = Character
	self.Root = Character:FindFirstChild('HumanoidRootPart')
	self.Trove = Trove.new()

	self.PlayerData = PlayerData
end

function TrailEffect:OnStart()
    --> Spawn Loop Which Can Be Interrupted
	local lastPosition = Vector3.zero
	local lastSpawned = 0

	local DashDirection = self.PlayerData.BodyLook
	if self.PlayerData.MoveDirection.Magnitude > 0 then
		DashDirection = self.PlayerData.MoveDirection
	end

	self.Trove:Connect(RunS.Stepped, function()
		if os.clock() - lastSpawned > .4 or  
			(self.Root.Position - lastPosition).Magnitude > 2.5
		then
			lastSpawned = os.clock()
			lastPosition = self.Root.Position
			
			local Position = self.Root.Position
			local Direction = DashDirection
			
			self:Trail(
				{Position, Direction}
			)
		end
	end)

	--> Sound Rendering

	local Torso = self.Character:FindFirstChild('Torso')
	local Sound = require(Modules.Sound)

	Sound:Create(
		Tree.Find(FlashStepAssets, 'Sounds/Dash').SoundId,
		Torso,
		false,
		.3
	)

	Sound:Create(
		Tree.Find(FlashStepAssets, 'Sounds/Shockwave').SoundId,
		Torso,
		false,
		.13
	)
end

function TrailEffect:Trail(location)
	local coreColors = CoreData[self.Character:GetAttribute('Core')]
	local pos, dir = unpack(location)
	
	local newTrail = FlashStepAssets.Trail:Clone()

	newTrail.CFrame = CFrame.new(pos, pos + dir) * CFrame.Angles(0,math.rad(90),math.rad(90))
	newTrail.Color = coreColors.Primary
	newTrail.Parent = workspace.Terrain
	
	local newGhost = FlashStepAssets.Ghost:Clone()
	newGhost.Parent = workspace.Terrain
	
	for _, ghostPart in newGhost:GetChildren() do
		local sourcePart = self.Character:FindFirstChild(ghostPart.Name)
		if sourcePart then
			ghostPart.CFrame = sourcePart.CFrame
			ghostPart.Color = coreColors.Highlights
			
			game.TweenService:Create(
				ghostPart,
				TweenInfo.new(.3, Enum.EasingStyle.Cubic),
				{Transparency = 1}
			):Play()
		end
	end
	
	task.delay(.3, function()
		newGhost:Destroy()
	end)
	
	game.TweenService:Create(
		newTrail,
		TweenInfo.new(.3, Enum.EasingStyle.Cubic),
		{
            Transparency = 1, 
            CFrame = newTrail.CFrame * CFrame.Angles(0,5,0)
        }
	):Play()
	
	task.delay(.3, function()
		newTrail:Destroy()
	end)
end

function TrailEffect:OnDestroy()
	self.Trove:Clean()
end

return TrailEffect