local RepS = game:GetService('ReplicatedStorage')
local Modules = RepS.Modules
local Value = require(Modules.Value)
local Spring = require(Modules.Spring)

local Packages = RepS.Packages
local Trove = require(Packages.Trove)

local RunS = game:GetService('RunService').Stepped
local TweenS = game:GetService('TweenService')
local CAS = game:GetService('ContextActionService')

local Character = script.Parent
local Root = Character:WaitForChild('HumanoidRootPart')
local Waist = Root:WaitForChild('RootJoint')
local Humanoid = Character:WaitForChild('Humanoid')
local Animator = Humanoid:WaitForChild('Animator')

--> Loading Animations
local AnimationIDs = {
	Idle = 7896578938,
	Jump = 7896562616,
	Walk = 7896559582,
	Run = 7896557091,
	Fall = 15298428233,
	Land = 17769623788,
	Roll = 16747851690,
	Dive = 17853941306
}

local Tracks = {}
for AnimName, ID in AnimationIDs do
	local AnimationInst = Instance.new('Animation')
	AnimationInst.AnimationId = 'rbxassetid://'..ID
	AnimationInst.Parent = Character
	Tracks[AnimName] = Animator:LoadAnimation(AnimationInst)
end 

local RepS = game:GetService('ReplicatedStorage')
local Modules = RepS.Modules
local Spark = require(Modules.Spark)

local MovementEnabled = Spark.Property('MovementEnabled', true)
MovementEnabled.Changed:Connect(function(_, enabled)
	if enabled then
		--> Unbind movement keys
	end
end)

local MaxRunSpeed = Spark.Property('MaxRunSpeed', 20)
local RunSpeed = Spring.new(MaxRunSpeed:Get())
RunSpeed.Speed = 20
local AirSpeed = Spring.new(0)
AirSpeed.Speed = 2

local WaistTilt = Spring.new(Vector2.zero)
WaistTilt.Speed = 15
local WaistC0 = Waist.C0
local MaxWaistTiltZ = 10
local MaxWaistTiltX = 10

local Running = Value.new(false)
local OnGround = Value.new(false)
local Jumping = Value.new(false)
local WhenJumped = 0

MaxRunSpeed.Changed:Connect(function(_, newMaxRunSpeed)
	if Running:Get() and OnGround:Get() then
		RunSpeed.Target = newMaxRunSpeed or 20
	end
end)

RunS:Connect(function()
	local Velocity = (Root.Velocity * Vector3.new(1,0,1)).Magnitude
	local MoveDirection = Humanoid.MoveDirection.Magnitude

	Running:Set(OnGround:Get() and ((Velocity >= 10) or (MoveDirection > 0)))
	
	if OnGround:Get() then
		Humanoid.WalkSpeed = RunSpeed.Position
		Tracks['Run']:AdjustSpeed(RunSpeed.Position/20)
	else
		Humanoid.WalkSpeed = AirSpeed.Position * 1.25
	end
	
	local MoveDirection = Root.CFrame:VectorToObjectSpace(Humanoid.MoveDirection)
	WaistTilt.Target = Vector2.new(
		math.rad(-MoveDirection.Z) * MaxWaistTiltZ,
		math.rad(-MoveDirection.X) * MaxWaistTiltX
	)
	
	Waist.C0 = WaistC0 * CFrame.Angles(
		WaistTilt.Position.X,
		WaistTilt.Position.Y,
		0
	)
end)

Humanoid.StateChanged:Connect(function(_, new)
	if new == Enum.HumanoidStateType.Running 
		or new == Enum.HumanoidStateType.Landed
	then
		OnGround:Set(true)
		Jumping:Set(false)
	else
		OnGround:Set(false)
	end
	
	if new == Enum.HumanoidStateType.Jumping then
		Jumping:Set(true)
	end
end)

local airTrove = Trove.new()
local diveRayParams = RaycastParams.new()
diveRayParams.FilterType = Enum.RaycastFilterType.Include
diveRayParams.FilterDescendantsInstances = {workspace.Terrain.Base}

local inDive = false

OnGround.Changed:Connect(function(_, grounded)
	--print(grounded and 'On Ground' or 'In Air')
	
	airTrove:Clean()
	
	if grounded then
		Tracks['Fall']:Stop()
		
		local airTime = os.clock() - WhenJumped
		local landVel = Root.Velocity.Y
		local moveVel = (Root.Velocity * Vector3.new(1,0,1)).Magnitude
		
		if inDive then
			Tracks['Roll']:Play()
			Tracks['Roll']:AdjustSpeed(1.5)
		else
			if airTime > .5 and landVel < -100 then
				if moveVel > 10 then
					Tracks['Roll']:Play()
					Tracks['Roll']:AdjustSpeed(1.5)
				else
					Tracks['Land']:Play(0)
					Tracks['Land']:AdjustSpeed(1.5)
				end
			else
				Tracks['Land']:Play(.5)
				Tracks['Land']:AdjustSpeed(1.5)
			end
		end
		
		Tracks['Idle']:Play(.5)
	else
		Tracks['Fall']:Play(.5)
		Tracks['Idle']:Stop()
		WhenJumped = os.clock()
		
		airTrove:Connect(RunS, function()
			local fallSpeed = Root.Velocity.Y
			--print(fallSpeed)
			if fallSpeed >= -50 then return end
			
			local fallHeight = workspace:Raycast(
				Root.Position,
				-Vector3.yAxis * 30,
				diveRayParams
			)
			if fallHeight then return end
			
			Tracks['Fall']:Stop(2)
			Tracks['Dive']:Play(1)
			
			inDive = true
			
			airTrove:Clean()
			
			airTrove:Add(function()
				Tracks['Dive']:Stop()
			end)
		end)
	end
	
	inDive = false
end)

Running.Changed:Connect(function(_, running)
	--print(running and 'Running' or 'Idle')
	
	if running and OnGround:Get() then
		Tracks['Run']:Play(1)
		RunSpeed.Target = MaxRunSpeed:Get() or 20
		RunSpeed.Speed = 15
	else
		Tracks['Run']:Stop()
		RunSpeed.Target = 1
		RunSpeed.Speed = 5
	end
end)

Jumping.Changed:Connect(function(_, jumping)
	--print(jumping and 'Jumping' or 'Landed')
	if jumping then
		Tracks['Jump']:Play()
		
		AirSpeed.Position = RunSpeed.Position
		AirSpeed.Target = 0
		AirSpeed.Speed = 2
		WhenJumped = os.clock()	
	end
end)