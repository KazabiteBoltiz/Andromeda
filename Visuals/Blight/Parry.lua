local RepS = game:GetService('ReplicatedStorage')
local Packages = RepS.Packages
local ReFX = require(Packages.ReFX)
local Tree = require(Packages.Tree)
local Trove = require(Packages.Trove)

local Modules = RepS.Modules
local GetPath = require(Modules.GetPath)

local GameData = RepS.GameData
local CoreData = require(GameData.CoreColors)

local TS = game:GetService('TweenService')
local RunS = game:GetService('RunService')

local Visuals = RepS.Visuals

local Parry = ReFX.CreateEffect(
    GetPath(Visuals, script)
)

local Assets = RepS.Assets
local ParryAssets = Tree.Find(Assets, 'Melee/Blight/Block/Parry')

local TS = game:GetService('TweenService')

local function GetCFrameOffset(pos, angle, mult)
    return CFrame.new(
        math.random(-pos * mult, pos * mult)/mult,
        math.random(-pos * mult, pos * mult)/mult,
        math.random(-pos * mult, pos * mult)/mult
    ) * CFrame.Angles(
        math.rad(math.random(-angle * mult, angle * mult)/mult),
        math.rad(math.random(-angle * mult, angle * mult)/mult),
        math.rad(math.random(-angle * mult, angle * mult)/mult)
    )
end

function Parry:OnConstruct(Character, PlayerData)
    self.DestroyOnEnd = false
    self.MaxLifetime = 1

    self.Character = Character
    self.Root = self.Character:FindFirstChild('HumanoidRootPart')
    self.Torso = self.Character:FindFirstChild('Torso')
    self.Trove = Trove.new()
    self.PlayerData = PlayerData
end

function Parry:OnStart()
    local Sound = require(Modules.Sound)
    Sound:Create(
        Tree.Find(ParryAssets, 'ParrySound').SoundId,
        self.Torso,
        false,
        .1
    )

    --> Parry Highlight
    local ParryFill = Tree.Find(ParryAssets, 'Fill'):Clone()
    ParryFill.Parent = self.Character
    self.Trove:Add(ParryFill)

    local ParryFillTw = TS:Create(
        ParryFill,
        TweenInfo.new(.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
        {FillTransparency = .6, OutlineTransparency = .6}
    )
    ParryFillTw:Play()
    self.Trove:Add(ParryFillTw, 'Cancel')

    --> Parry Blink
    local BlinkAtt = Instance.new('Attachment')
    BlinkAtt.Parent = self.Torso
    self.Trove:Add(BlinkAtt)

    local ParryBlink = Tree.Find(ParryAssets, 'Blink'):Clone()
    ParryBlink.Parent = BlinkAtt
    self.Trove:Add(ParryBlink)

    self.Trove:Add(task.delay(.05, function()
        ParryBlink:Emit(1)
    end))

    --> Parry Light
    local ParryLight = Tree.Find(ParryAssets, 'ParryLight'):Clone()
    ParryLight.Parent = BlinkAtt
    self.Trove:Add(ParryLight)

    local ParryLightTw = TS:Create(
        ParryLight,
        TweenInfo.new(.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
        {Brightness = 0}
    )
    ParryLightTw:Play()
    self.Trove:Add(ParryLightTw, 'Cancel')

    --> Parry Dash
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
	dashVel.VectorVelocity = DashDirection * 80
	dashVel.Attachment0 = dashAtt
	dashVel.MaxForce = 10 ^ 5
	dashVel.Parent = self.Character
	dashTrove:Add(dashVel)
	
	dashTrove:Connect(RunS.Stepped, function(dt)
		dashVel.VectorVelocity = dashVel.VectorVelocity:Lerp(Vector3.zero, .15)
		if dashVel.VectorVelocity.Magnitude < 10 then
			dashTrove:Clean()
		end
	end)

    --> Parry Ghost
    local ParryGhost = Tree.Find(ParryAssets, 'Ghost'):Clone()
    ParryGhost.Parent = workspace.Terrain
    
    for _, ghostPart in ParryGhost:GetChildren() do
        local realBodyPart = self.Character:FindFirstChild(ghostPart.Name)
        ghostPart.CFrame = realBodyPart.CFrame

        local fadeTw = TS:Create(
            ghostPart,
            TweenInfo.new(.5, Enum.EasingStyle.Cubic),
            {
                Transparency = 1, 
                CFrame = ghostPart.CFrame * GetCFrameOffset(.3, 30, 50),
                Size = ghostPart.Size * (Vector3.one * 1.2)
            }
        )
        fadeTw.Completed:Connect(function()
            ghostPart:Destroy()
        end)
        fadeTw:Play()
    end

    task.delay(1, function()
        ParryGhost:Destroy()
    end)
end

function Parry:OnDestroy()
    self.Trove:Clean()
end

return Parry