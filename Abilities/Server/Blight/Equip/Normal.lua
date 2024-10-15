local ContextActionService = game:GetService('ContextActionService')
local ServerS = game:GetService('ServerScriptService')
local Systems = ServerS.Systems
local Ability = Systems.Ability
local AbilityStatus = require(Ability.Status)

local RepS = game:GetService('ReplicatedStorage')
local Packages = RepS.Packages
local Trove = require(Packages.Trove)
local Tree = require(Packages.Tree)

local Modules = RepS.Modules
local GetPath = require(Modules.GetPath)

local Players = game:GetService('Players')

local Assets = RepS.Assets
local WeaponAssets = Tree.Find(
    Assets, 
    'Melee/Blight'
)

local WeaponName = GetPath(
    ServerS.Abilities,
    script.Parent.Parent,
    true
)

local Normal = {
    Status = AbilityStatus.Open,
    EffectPaths = {
        Equip = 'Blight/Equip'
    },
    AbilityPaths = {}
}

function Normal.Start(Battle, Ability, PlayerData)
    local Character = Battle.Character
    local Humanoid = Character:FindFirstChild('Humanoid')
    local WeaponGrip = Character:FindFirstChild('WeaponGrip')

    Battle.Status:Set(AbilityStatus.Locked)

    local ActiveWeapon = Battle.ActiveWeapon

    Ability.Trove:Add(function()
        Battle.Status:Set(AbilityStatus.Open)
    end)

    local function Unequip()
        Battle.ActiveWeapon.Trove:Clean()
        Battle.ActiveWeapon = nil
        
        Battle.Status:Set(AbilityStatus.Open)
    end

    local function Equip()
        if ActiveWeapon then
            ActiveWeapon.Trove:Clean()
        end

        local newTrove = Trove.new()
        Battle.ActiveWeapon = {
            Name = WeaponName,
            Trove = newTrove,
            Combo = 1
        }

        --> Creating The Weapon
        local WeaponClone = Tree.Find(
            WeaponAssets,
            'Toggle/Tool',
            'Model'
        ):Clone()
        newTrove:Add(WeaponClone)

        WeaponClone:PivotTo(
            WeaponGrip.CFrame *
            WeaponClone:GetAttribute('Grip')
        )
        
        local WeaponWeld = Instance.new('WeldConstraint')
        WeaponWeld.Part1 = WeaponClone.Grip
        WeaponWeld.Part0 = WeaponGrip        
        newTrove:Add(WeaponWeld)

        WeaponWeld.Parent = Character
        WeaponClone.Parent = Character

        --> Animations And Sounds

        local EquipAnim = Tree.Find(
            WeaponAssets,
            'Toggle/Animations/Equip'
        )
        local EquipTrack = Humanoid:LoadAnimation(EquipAnim)
        newTrove:Add(EquipTrack)
        EquipTrack:Play()

        local CraterEffect = Normal.Effects.Equip.new(
            Character
        )
        CraterEffect:Start(Players:GetChildren())

        --> Idle Animation Setup
        local IdleAnim = Tree.Find(
            WeaponAssets, 
            'Toggle/Animations/Idle'
        )
        local IdleTrack = Humanoid:LoadAnimation(IdleAnim)
        newTrove:Add(function()
            IdleTrack:Stop(.2)
        end)
        IdleTrack:Play()

        Ability.Trove:Add(task.delay(.3, function()
            Battle.Status:Set(AbilityStatus.Open)
        end))
    end

    local WantsToUnequip = PlayerData.WantToUnequip
    if WantsToUnequip then
        if ActiveWeapon and ActiveWeapon.Name == WeaponName then
            Unequip()
        end
    else
        if ActiveWeapon and ActiveWeapon.Name == WeaponName then
            Battle.Status:Set(AbilityStatus.Open)
            return
        end
        Equip()
    end
end

return Normal