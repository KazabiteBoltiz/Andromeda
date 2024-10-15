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

local Blink = ReFX.CreateEffect(
    GetPath(Visuals, script)
)

local Assets = RepS.Assets
local DashAssets = Tree.Find(Assets, 'FlashStep')

local TS = game:GetService('TweenService')

function Blink:OnConstruct(Character)
    self.DestroyOnEnd = false
    self.MaxLifetime = 1

    self.Character = Character
    self.Root = self.Character:FindFirstChild('HumanoidRootPart')
    self.Torso = self.Character:FindFirstChild('Torso')
    self.Trove = Trove.new()
end

function Blink:OnStart()
    local CoreColor = CoreData[self.Character:GetAttribute('Core')]

    local BlinkEffect = DashAssets.Blink:Clone()
    local FlashFill = DashAssets.FlashFill:Clone()
    local DashLight = DashAssets.DashLight:Clone()

    FlashFill.Parent = self.Character
    BlinkEffect.Parent = self.Root.RootAttachment
    DashLight.Parent = self.Root

    task.wait()

    DashLight.Color = CoreColor.Primary
    TS:Create(
        DashLight,
        TweenInfo.new(.6, Enum.EasingStyle.Cubic),
        {Brightness = 0}
    ):Play()

    local powerDownTask = task.delay(.3, function()
        TS:Create(
            FlashFill,
            TweenInfo.new(.5, Enum.EasingStyle.Cubic),
            {FillTransparency = 1}
        ):Play()

        BlinkEffect:Emit(1)
    end)
    self.Trove:Add(powerDownTask)

    task.delay(1, function()
        FlashFill:Destroy()
        BlinkEffect:Destroy()
    end)
end

function Blink:OnDestroy()
    self.Trove:Clean()
end

return Blink