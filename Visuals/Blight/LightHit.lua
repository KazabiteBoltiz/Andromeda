local RepS = game:GetService('ReplicatedStorage')
local Packages = RepS.Packages
local ReFX = require(Packages.ReFX)
local Tree = require(Packages.Tree)
local Trove = require(Packages.Trove)

local Modules = RepS.Modules
local GetPath = require(Modules.GetPath)

local GameData = RepS.GameData
local CoreData = require(GameData.CoreColors)

local Visuals = RepS.Visuals

local LightHit = ReFX.CreateEffect(
    GetPath(Visuals, script)
)

local Assets = RepS.Assets
local LightHitAssets = Tree.Find(Assets, 'Melee/Blight/Hit')

local TS = game:GetService('TweenService')

function LightHit:OnConstruct(Humanoid)
    self.DestroyOnEnd = false
    self.MaxLifetime = 1

    self.Humanoid = Humanoid
    self.Character = Humanoid.Parent
    self.Torso = self.Character:FindFirstChild('Torso')
    self.Trove = Trove.new()
end

function LightHit:OnStart()
    local Sound = require(Modules.Sound)
    Sound:Create(
        Tree.Find(LightHitAssets, 'Sounds/Hit'..math.random(1,2)).SoundId,
        self.Torso,
        false,
        .2
    )
end

function LightHit:OnDestroy()
    self.Trove:Clean()
end

return LightHit