

local RepS = game:GetService('ReplicatedStorage')
local Packages = RepS.Packages
local ReFX = require(Packages.ReFX)
local Tree = require(Packages.Tree)

local Modules = RepS.Modules
local GetPath = require(Modules.GetPath)

local Visuals = RepS.Visuals
local CraterCreator = require(Visuals.CraterCreator)

local Assets = RepS.Assets
local CraterAssets = Tree.Find(
    Assets, 
    'Crater'
)

local DashCrater = ReFX.CreateEffect(
    GetPath(Visuals, script)
)

function DashCrater:OnConstruct()
    self.DestroyOnEnd = false
    self.MaxLifetime = 3
end

function DashCrater:OnStart(Character, ...)
    local Root = Character:FindFirstChild('HumanoidRootPart')

    local position = Root.Position

    local CollideParams = RaycastParams.new()
    CollideParams.FilterType = Enum.RaycastFilterType.Include
    CollideParams.FilterDescendantsInstances = {workspace.Terrain.Base}
    
    local craterRay = workspace:Raycast(
        position,
        -Vector3.yAxis * 4,
        CollideParams
    )

    if craterRay then
        local dashCenter = CraterAssets.Root:Clone()
        dashCenter.Parent = workspace.Terrain
        dashCenter.CFrame = CFrame.new(
            craterRay.Position,
            craterRay.Position + craterRay.Normal
        ) * CFrame.Angles(math.rad(90),0,0)

        CraterCreator.CreateCircle(
            dashCenter,
            ...
        )
        
        local Sound = require(Modules.Sound)
        Sound:Create(
        	Tree.Find(
                Assets,
                'Crater/Fissure'
            ).SoundId,
        	dashCenter.Position,
            false,
        	.08
        )

        for _, particle in dashCenter:GetDescendants() do
            task.delay(particle:GetAttribute('EmitDelay'), function()
                if not particle:IsA('ParticleEmitter') then return end
                particle:Emit(particle:GetAttribute('EmitCount'))
            end)
        end
    end
end

function DashCrater:OnDestroy() end

return DashCrater