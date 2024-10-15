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

local Visuals = RepS.Visuals

local Guard = ReFX.CreateEffect(
    GetPath(Visuals, script)
)

local Assets = RepS.Assets
local GuardAssets = Tree.Find(Assets, 'Melee/Blight/Block/Guard')

local TS = game:GetService('TweenService')

function Guard:OnConstruct(Character)
    self.DestroyOnEnd = false
    self.MaxLifetime = math.huge

    self.Character = Character
    self.Root = self.Character:FindFirstChild('HumanoidRootPart')
    self.Torso = self.Character:FindFirstChild('Torso')
    self.Trove = Trove.new()
end

function Guard:OnStart()
    local Sound = require(Modules.Sound)
    Sound:Create(
        Tree.Find(GuardAssets, 'GuardSound').SoundId,
        self.Torso,
        false,
        .1
    )

    local GuardFill = Tree.Find(GuardAssets, 'Fill'):Clone()
    GuardFill.Parent = self.Character

    local GuardTransparency = GuardFill.FillTransparency
    local enterTween = TS:Create(
        GuardFill,
        TweenInfo.new(.2, Enum.EasingStyle.Cubic),
        {FillTransparency = GuardTransparency}
    )

    enterTween:Play()

    self.Trove:Add(function()
        enterTween:Cancel()

        local exitTween = TS:Create(
            GuardFill,
            TweenInfo.new(.2, Enum.EasingStyle.Cubic),
            {FillTransparency = 1}
        )

        exitTween:Play()

        exitTween.Completed:Connect(function()
            GuardFill:Destroy()
        end)
    end)
end

function Guard:OnDestroy()
    self.Trove:Clean()
end

return Guard