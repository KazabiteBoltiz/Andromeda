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

local Light = ReFX.CreateEffect(
    GetPath(Visuals, script)
)

local Assets = RepS.Assets
local LightAssets = Tree.Find(Assets, 'Melee/Blight/Light')

local TS = game:GetService('TweenService')

function Light:OnConstruct(Character, PlayerData)
    self.DestroyOnEnd = false
    self.MaxLifetime = 1

    self.Character = Character
    self.Root = self.Character:FindFirstChild('HumanoidRootPart')
    self.Torso = self.Character:FindFirstChild('Torso')
    self.PlayerData = PlayerData
    self.Trove = Trove.new()
end

function Light:OnStart()
    local Sound = require(Modules.Sound)
    Sound:Create(
        Tree.Find(LightAssets, 'Sounds/Slash1').SoundId,
        self.Torso,
        false,
        .2
    )
end

function Light:OnDestroy()
    self.Trove:Clean()
end

return Light