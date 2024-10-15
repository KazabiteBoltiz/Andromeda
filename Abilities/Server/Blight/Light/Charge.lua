local RepS = game:GetService('ReplicatedStorage')
local ServerS = game:GetService('ServerScriptService')
local Systems = ServerS.Systems
local Ability = Systems.Ability
local AbilityStatus = require(Ability.Status)

local Modules = RepS.Modules
local Spark = require(Modules.Spark)
local PlayerDataRequest = Spark.Event('PlayerDataRequest')

local Packages = RepS.Packages
local Tree = require(Packages.Tree)
local Signal = require(Packages.Signal)

local Assets = RepS.Assets

local Charge = {
    Status = AbilityStatus.Open,
    EffectPaths = {},
    AbilityPaths = {}
}

function Charge.Start(Battle, Ability)
    Battle.Status:Set(AbilityStatus.Locked)

    local Character = Battle.Character
    local Humanoid = Character:FindFirstChild('Humanoid')

    local ActiveWeapon = Battle.ActiveWeapon
    local Combo = ActiveWeapon.Combo

    if ActiveWeapon.SwingTrack then
        ActiveWeapon.SwingTrack:Stop()
    end

    --> Charge Animation
    local ChargeAssets = Tree.Find(
        Assets, 
        'Melee/Blight/Charge'
    ).Animations
    local ChargeAnim = ChargeAssets['PreSlash'..Combo]
    local ChargeTrack = Humanoid:LoadAnimation(ChargeAnim)
    ChargeTrack:Play(.1)
    ChargeTrack:AdjustSpeed(2)
    Ability.Trove:Add(function()
        ChargeTrack:Stop(0)
    end)

    Ability.Trove:Add(function()
        Battle.Status:Set(AbilityStatus.Open)
    end)

    Ability.Trove:Add(task.delay(.2, function()
        Ability:Switch('Swing')
    end))
end

return Charge