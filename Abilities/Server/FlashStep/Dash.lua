local ServerS = game:GetService('ServerScriptService')
local Systems = ServerS.Systems
local Ability = Systems.Ability
local Abilities = ServerS.Abilities
local AbilityStatus = require(Ability.Status)

local RepS = game:GetService('ReplicatedStorage')
local Packages = RepS.Packages
local Tree = require(Packages.Tree)

local Modules = RepS.Modules
local GetPath = require(Modules.GetPath)
local Spark = require(Modules.Spark)
local AbilityRequest = Spark.Event('AbilityRequest')

local Assets = RepS.Assets
local DashAssets = Tree.Find(Assets, 'FlashStep')

local Players = game:GetService('Players')

local Dash = {
    Status = AbilityStatus.Open,
    EffectPaths = {
        Trail = 'FlashStep/Trail',
        Crater = 'FlashStep/Crater',
        Invisible = 'FlashStep/Invisible',
        Blink = 'FlashStep/Blink'
    },
    AbilityPaths = {
        Dash = 'FlashStep/Dash',
    }
}

local MovePath = 'FlashStep/Dash'

function Dash.Start(Battle, Ability, PlayerData)
    local Character = Battle.Character
    local Player = Players:GetPlayerFromCharacter(Character)

    Battle:Trigger(
        MovePath,
        'Start',
        PlayerData
    )

    --> Lock Ability
    Battle.Status:Set(AbilityStatus.Locked)

    --> Dash Animation
    local Humanoid = Character:FindFirstChild('Humanoid')
    local dashAnim = DashAssets.DashAnim
    local dashTrack = Humanoid:LoadAnimation(dashAnim)
    dashTrack:Play()
    Ability.Trove:Add(dashTrack)

    --> Blink Effect
    local BlinkEffect = Dash.Effects.Blink.new(
        Character
    )
    BlinkEffect:Start(Players:GetChildren())

    --> Trail Effect
    local TrailEffect = Dash.Effects.Trail.new(
        Character, PlayerData
    )
    Ability.Trove:Add(TrailEffect, 'Destroy')
    TrailEffect:Start(Players:GetChildren())

    --> Invisible Effect
    local InvisEffect = Dash.Effects.Invisible.new(
        Character
    )
    Ability.Trove:Add(InvisEffect, 'Destroy')
    InvisEffect:Start(Players:GetChildren())

    --> Start Crater
    local CraterEffect = Dash.Effects.Crater.new(
        Character, 
        9, 4, 0, 1,
        Vector3.new(5,1,.5)
    )
    CraterEffect:Start(Players:GetChildren())

    --> End Crater
    Ability.Trove:Add(task.delay(.3, function()
        local CraterEffect = Dash.Effects.Crater.new(
            Character,
            9, 3, 0, 1,
            Vector3.new(2,2,1)
        )
        CraterEffect:Start(Players:GetChildren())
    end))

    --> End Ability
    Ability.Trove:Add(function()
        Battle:Trigger(
            MovePath,
            'Destroy',
            PlayerData
        )

        Battle.Status:Set(AbilityStatus.Open)
        Battle:EquipStoredWeapon()
    end)

    task.delay(.5, function()
        Ability.Trove:Clean()
    end)
end

return Dash