local Players = game:GetService('Players')
local RepS = game:GetService('ReplicatedStorage')
local Packages = RepS.Packages
local Trove = require(Packages.Trove)

local Abilities = RepS.Abilities
local RunS = game:GetService('RunService')

local Dash = {}
Dash.__index = Dash

function Dash.new(Character, PlayerData)
    local self = setmetatable({}, Dash)

    self.Character = Character
    self.Root = Character:FindFirstChild('HumanoidRootPart')
    self.Player = Players:GetPlayerFromCharacter(Character)
    self.PlayerData = PlayerData
    self.Trove = Trove.new()

    local Components = RepS.Components
    if self.Player then
        self.Camera = require(
            Components.Camera
        ):GetAll()[1]
    end

    return self
end

function Dash:Start()
    self:StartShake()

    local dashTrove = self.Trove:Extend()
	
	local dashAtt = Instance.new('Attachment')
	dashAtt.Orientation = Vector3.new(0,90,0)
	dashAtt.Parent = self.Root
	dashTrove:Add(dashAtt)
	
	local DashDirection = self.PlayerData.MoveDirection
	if DashDirection.Magnitude <= 0 then
		DashDirection = self.PlayerData.BodyLook
	end

	local dashVel = Instance.new('LinearVelocity')
	dashVel.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	dashVel.RelativeTo = Enum.ActuatorRelativeTo.World
	dashVel.VectorVelocity = DashDirection * 150
	dashVel.Attachment0 = dashAtt
	dashVel.MaxForce = 10 ^ 5
	dashVel.Parent = self.Character
	dashTrove:Add(dashVel)
	
	dashTrove:Connect(RunS.Stepped, function(dt)
		dashVel.VectorVelocity = dashVel.VectorVelocity:Lerp(Vector3.zero, .1)
		if dashVel.VectorVelocity.Magnitude < 10 then
			dashTrove:Clean()
		end
	end)

    local endTask = task.delay(.4, function()
		local CollideParams = RaycastParams.new()
		CollideParams.FilterType = Enum.RaycastFilterType.Include
		CollideParams.FilterDescendantsInstances = {workspace.Terrain.Base}

		local craterRay = workspace:Raycast(
            self.Root.Position,
            -Vector3.yAxis * 4,
            CollideParams
        )
		
		if craterRay then
			self:CraterShake()
		end
	end)
	self.Trove:Add(endTask)
end

function Dash:StartShake()
    if not self.Camera then return end

    self.Camera:Shake(
        'Zoom', 40, 20, .2, 15
    )
    self.Camera:Shake(
        'Bump', 40, -10, .2, 8
    )
end

function Dash:CraterShake()
    if not self.Camera then return end

    self.Camera:Shake(
        'Bump', 40, -5, .08, 35
    )
end

return Dash