local Players = game:GetService('Players')
local RepS = game:GetService('ReplicatedStorage')
local Packages = RepS.Packages
local Trove = require(Packages.Trove)
local Tree = require(Packages.Tree)

local Abilities = RepS.Abilities
local RunS = game:GetService('RunService')

local Modules = RepS.Modules
local MHitbox = require(Modules.MuchachoHitbox)
local Spark = require(Modules.Spark)
local HitboxEvent = Spark.Event('HitboxRequest')

local Assets = RepS.Assets

local Swing = {}
Swing.__index = Swing

function Swing.new(Character, PlayerData)
    local self = setmetatable({}, Swing)

    self.Character = Character
    self.Root = Character:FindFirstChild('HumanoidRootPart')
    self.Humanoid = Character:FindFirstChild('Humanoid')
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

function Swing:Start()
    local Combo = self.PlayerData.Combo

    local hitboxOverlap = OverlapParams.new()
    hitboxOverlap.FilterDescendantsInstances = {self.Character}
    hitboxOverlap.FilterType = Enum.RaycastFilterType.Exclude

    local hitbox = MHitbox.CreateHitbox()
    hitbox.Size = 4
    hitbox.OverlapParams = hitboxOverlap
    hitbox.Shape = Enum.PartType.Ball
    hitbox.CFrame = self.Root
    hitbox.Offset = CFrame.new(0,0,-2.2)
    hitbox.Visualizer = true

    self.Trove:Add(function()
        if hitbox.Destroy then
            hitbox:Destroy()
        end
    end)

    local targets = {}

    self.Trove:Connect(hitbox.Touched, function(_, hum)
        table.insert(targets, hum)
    end)

    -- if self.Camera then
    --     self.Camera:Shake(
    --         'Bump',
    --         60, -8, .05, 30
    --     )
    -- end

    if self.Camera then
        self.Camera:Shake(
            'Bump',
            30, -4, .1, 10
        )
    end

    self.Trove:Add(task.delay(Combo < 3 and 0 or .05, function()
        hitbox:Start()
        task.wait(.05)
        hitbox:Stop()
        
        HitboxEvent:Fire(self.PlayerData.ContextId, targets)
    end))
end

return Swing