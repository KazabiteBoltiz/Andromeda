local RepS = game:WaitForChild('ReplicatedStorage')
local Packages = RepS.Packages
local Component = require(Packages.Component)
local Trove = require(Packages.Trove)

local Modules = RepS.Modules
local Spring = require(Modules.Spring)

local CameraEffects = script

if not game.Players.LocalPlayer then
	return {}
end

workspace.CurrentCamera:AddTag('Camera')

local Camera = Component.new{
	Tag = "Camera",
	Ancestors = {workspace},
	Extensions = {}
}

function Camera:Start()
	local camera = self.Instance
	self.cameraSpring = Spring.new(Vector3.new())
	self.cameraSpring.Speed = 30
	
	local defaultFOV = workspace.CurrentCamera.FieldOfView
	self.cameraFOVSpring = Spring.new(0)
	self.cameraFOVSpring.Speed = 30
	
	local oldOffset = CFrame.new()
	local offset = CFrame.new()
	
	self.shakeTrove = Trove.new()
	
	--Net:Connect('CameraRequest', function(...)
	--	self:Shake(...)
	--end)
	
	game:GetService("RunService").RenderStepped:Connect(function(delta)
		camera.CFrame *= oldOffset:Inverse()
		camera.CFrame *= offset
		oldOffset = offset
		
		offset = CFrame.Angles(
			math.floor(self.cameraSpring.Position.X * 1e5) / 1e5,
			math.floor(self.cameraSpring.Position.Y * 1e5) / 1e5,
			math.floor(self.cameraSpring.Position.Z * 1e5) / 1e5
		)  
		
		camera.FieldOfView = defaultFOV + self.cameraFOVSpring.Position
	end)
end

function Camera:Shake(event, ...)
	--self.shakeTrove:Clean()

	local CameraEffect = require(CameraEffects:FindFirstChild(event))
	local extraArgs = {...}
	table.insert(extraArgs, self.cameraSpring)
	table.insert(extraArgs, self.cameraFOVSpring)

	local shakeTask = task.spawn(function()
		CameraEffect(unpack(extraArgs))
	end)

	-- self.shakeTrove:Add(shakeTask)
end

return Camera