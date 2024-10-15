local ContextActionService = game:GetService('ContextActionService')
local HttpService = game:GetService('HttpService')
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
local Spark = require(Modules.Spark)
local InputRequest = Spark.Event('InputRequest')
local MaxRunSpeed = Spark.Property('MaxRunSpeed')

local Players = game:GetService('Players')
local Http = game:GetService('HttpService')

local Assets = RepS.Assets
local ParryAssets = Tree.Find(
    Assets, 
    'Melee/Blight/Block/Parry'
)

local WeaponName = GetPath(
    ServerS.Abilities, 
    script.Parent.Parent, 
    true
)

local Parry = {
    Status = AbilityStatus.Open,
    EffectPaths = {
        Parry = 'Blight/Parry'
    },
    AbilityPaths = {'Blight/Block'}
}

function Parry.Start(Battle, Ability, PlayerData)
    local Character = Battle.Character
    local Player = Players:GetPlayerFromCharacter(Character)
    local Humanoid = Character:FindFirstChild('Humanoid')
    local WeaponGrip = Character:FindFirstChild('WeaponGrip')

    Battle.Status:Set(AbilityStatus.Locked)
    
    local ContextId = Http:GenerateGUID(false)
    PlayerData.ContextId = ContextId

    --> Slow The Player Down
    if Player then
        MaxRunSpeed:SetFor(Player, 5)

        Ability.Trove:Add(function()
            MaxRunSpeed:SetFor(Player, 20)
        end)
    end

    --> Receive Block Cancel Signal
    Battle:Trigger(
        'Blight/Block',
        'Start',
        PlayerData
    )

    --> Parry Visuals
    local ParryEffect = Parry.Effects.Parry.new(
        Character,
        PlayerData
    )
    ParryEffect:Start(Players:GetChildren())
    Ability.Trove:Add(ParryEffect, 'Destroy')

    --> Parry Animation
    local parryAnim = ParryAssets.ParryAnim
    local parryTrack = Humanoid:LoadAnimation(parryAnim)
    parryTrack:Play()
    Ability.Trove:Add(function()
        parryTrack:Stop(.3)
    end)

    Ability.Trove:Connect(InputRequest.Fired, function(player, context)
        if Character == player.Character and
            context == ContextId
        then
            PlayerData.Cancelled = true
        end
    end)

    Ability.Trove:Add(function()
        Battle:Trigger(
            'Blight/Block',
            'Destroy',
            PlayerData
        )
    end)

    Ability.Trove:Add(function()
        Battle.Status:Set(AbilityStatus.Open)
    end)

    Ability.Trove:Add(task.delay(.3, function()
        Ability:Switch('Guard', PlayerData)
    end))
end

return Parry