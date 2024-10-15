local RepS = game:GetService('ReplicatedStorage')
local Packages = RepS.Packages
local ReFX = require(Packages.ReFX)
local Tree = require(Packages.Tree)
local Trove = require(Packages.Trove)

local Modules = RepS.Modules
local GetPath = require(Modules.GetPath)

local Visuals = RepS.Visuals

local Invisible = ReFX.CreateEffect(
    GetPath(Visuals, script)
)

function Invisible:OnConstruct(Character)
    self.DestroyOnEnd = false
    self.MaxLifetime = .4

    self.Character = Character
end

function Invisible:OnStart()
    self.partCache = {}

    self.Character.Head.Face.Transparency = 1

    for _, basePart in self.Character:GetChildren() do
        if basePart:IsA('BasePart') and basePart.Name ~= 'HumanoidRootPart' and basePart.Name ~= 'WeaponGrip' then
            basePart.Transparency = 1
            table.insert(self.partCache, {basePart, 'Transparency'})
            basePart.CanCollide = false
        end
    end

    for _, basePart in self.Character.Armor:GetChildren() do
        if basePart:IsA('BasePart') then
            basePart.Transparency = 1
            table.insert(self.partCache, {basePart, 'Transparency'})
        end
    end

    for _, basePart in self.Character.Core:GetChildren() do
        if basePart:IsA('BasePart') then
            basePart.Transparency = 1
            table.insert(self.partCache, {basePart, 'Transparency'})
        end
    end

    for _, basePart in self.Character.Outline:GetChildren() do
        if basePart:IsA('BasePart') then
            basePart.Transparency = 1
            table.insert(self.partCache, {basePart, 'Transparency'})
        end
    end

    for _, basePart in self.Character.Tattoos:GetChildren() do
        if basePart:IsA('Beam') then
            basePart.Enabled = false
            table.insert(self.partCache, {basePart, 'Enabled'})
        end
    end

    for _, basePart in self.Character.LeftHand:GetChildren() do
        if basePart:IsA('BasePart') then
            basePart.Transparency = 1
            table.insert(self.partCache, {basePart, 'Transparency'})
        end
    end

    for _, basePart in self.Character.RightHand:GetChildren() do
        if basePart:IsA('BasePart') then
            basePart.Transparency = 1
            table.insert(self.partCache, {basePart, 'Transparency'})
        end
    end
end

function Invisible:OnDestroy()
    self.Character.Head.Face.Transparency = 0

    for _, data in self.partCache do
        local basePart, property = unpack(data)
        if property == 'Transparency' then
            basePart[property] = 0
        else
            basePart[property] = true
        end
    end
end

return Invisible