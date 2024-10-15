local CraterModule = {}

------------------------------------------------------------------------------- Services

local TweenService = game:GetService("TweenService")
local workspace = workspace

------------------------------------------------------------------------------- Variables

local rp = RaycastParams.new()
rp.FilterDescendantsInstances = { workspace.Terrain.Base } --// Replace this with folders you want the craters to ignore
rp.FilterType = Enum.RaycastFilterType.Include

local Random = Random.new()

local FullCircle = 2 * math.pi

local Color = Color3.fromRGB(91, 91, 91)
local Material = Enum.Material.Basalt


------------------------------------------------------------------------------- Local Func

local function GetXAndZPositions(Angle: number, Radius: number): any
	local X = math.cos(Angle) * Radius 
	local Z = math.sin(Angle) * Radius
	return X, Z
end

local function CreateDebrisPart( Parent, Name, Size )
	
	local Attachment = Instance.new("Part")
	Attachment.Color = Color
	
	Attachment.BackSurface = Enum.SurfaceType.Smooth
	Attachment.TopSurface = Enum.SurfaceType.Smooth
	Attachment.BottomSurface = Enum.SurfaceType.Smooth
	Attachment.FrontSurface = Enum.SurfaceType.Smooth
	Attachment.LeftSurface = Enum.SurfaceType.Smooth
	Attachment.RightSurface = Enum.SurfaceType.Smooth
	
	Attachment.Material = Material
	Attachment.Anchored = true
	Attachment.CanCollide = false
	Attachment.Size = Size
	Attachment.Name = tostring(Name)
	Attachment.Parent = Parent
	
	return Attachment
end

------------------------------------------------------------------------------- Main Func


function CraterModule.CreateCircle( Part: BasePart, Number: number, Radius: number, lookAtOffset: number, Lifetime: number, Size: Vector3) : {}
	
	if Part == nil or Number == nil or Radius == nil or lookAtOffset == nil or Lifetime == nil then
		return
	end
	
	local Attachments = { }
	
	Part.Parent = workspace.Terrain
	
	local downRay = workspace:Raycast( Part.Position+Vector3.new(0,.1,0), Vector3.new(0,-1,0), rp ) --// Casting down from the middle of the crater
	
	local decision = true --// (1) This is used to ensure that only ~1/2 of the crater is randomly rotated, while the rest is facing directly at the lookAt
	for i = 1, Number do
		
		local Attachment = CreateDebrisPart( Part, i, Size )
		
		local Angle = i * (FullCircle / Number)
		local X, Z = GetXAndZPositions(Angle, Radius)

		local Position = ( Part.CFrame * CFrame.new(X, 0, Z) ).Position
		local LookAt = Part.Position + Vector3.new(0, lookAtOffset, 0)

		Attachment.CFrame = CFrame.lookAt(Position, LookAt) * CFrame.fromEulerAnglesXYZ(0, -math.pi / Random:NextNumber(1.85, 2), 0)
		Attachment.CFrame = CFrame.lookAt(Attachment.Position, LookAt)
		
		decision = not decision --// Toggling it from true/false & vice versa
		if decision then --// (2)
			Attachment.CFrame *= CFrame.Angles(math.rad(Random:NextNumber(10, 30)), math.rad(Random:NextNumber(1, 15)), 0)
		end
		
		local rayc = workspace:Raycast(Attachment.Position+Vector3.new(0,5,0), Vector3.new(0,-10,0), rp)
		if rayc then Attachment.Position = rayc.Position end
		
		Attachment.Position = Attachment.Position + Vector3.new(0,-1.1,0)
		
		local grass = Attachment:Clone() --// The part ontop of the debris
		grass.Size = Vector3.new(Attachment.Size.X+.5, .6, Attachment.Size.Z+.5)
		grass.CFrame = Attachment.CFrame * CFrame.new(0, (Attachment.Size.Y/2)+.3,0)
		
		if rayc then
			
			grass.Material = rayc.Material
			grass.MaterialVariant = rayc.Instance.MaterialVariant
			grass.Color = rayc.Instance.Color
				
			for _, v in rayc.Instance:GetChildren() do
				
				if v:IsA("Texture") or v:IsA("Decal") then --// Copying textures & decals over to the debris
					v:Clone().Parent = grass
				end
				
			end
			
		end
		
		grass.Parent = Attachment
		
		local model = Instance.new("Model")
		model.Parent = workspace.Terrain
		Attachment.Parent = model
		
		local sizeValue = Instance.new("NumberValue")
		sizeValue.Parent = Attachment
		sizeValue.Value = 1
		
		sizeValue.Changed:Connect(function(value)
			
			local success,msg = pcall(function() --// The script will spam error messages if you remove this because of how :ScaleTo works. I cba to fix it so I just made it shut up.
				model:ScaleTo(value)
			end)
			
		end)
		
		sizeValue.Value = 0
		
		TweenService:Create(sizeValue, TweenInfo.new(.05), {Value = Random:NextNumber(.9,1.3)}):Play()
		
		task.delay(Lifetime, function()
			
			TweenService:Create(sizeValue, TweenInfo.new(1), {Value = 0}):Play()

			task.wait(1.01)
			
			Attachment:Destroy()
			Part:Destroy()			
			
		end)
		
		table.insert(Attachments, Attachment)
	end
	
	return Attachments --// It returns the crater as an { array }
end

------------------------------------------------------------------------------- Module End

return CraterModule