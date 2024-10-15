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

local Equip = ReFX.CreateEffect(
    GetPath(Visuals, script)
)

local Assets = RepS.Assets
local EquipAssets = Tree.Find(Assets, 'Melee/Blight/Toggle')

local TS = game:GetService('TweenService')

function Equip:OnConstruct(Character)
    self.DestroyOnEnd = false
    self.MaxLifetime = 1

    self.Character = Character
    self.Root = self.Character:FindFirstChild('HumanoidRootPart')
    self.Torso = self.Character:FindFirstChild('Torso')
    self.Trove = Trove.new()
end

function Equip:OnStart()
    local Sound = require(Modules.Sound)
    Sound:Create(
        Tree.Find(EquipAssets, 'Sounds/Equip').SoundId,
        self.Torso,
        false,
        .2
    )
end

function Equip:OnDestroy()
    self.Trove:Clean()
end

return Equip