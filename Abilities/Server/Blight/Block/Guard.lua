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
local MaxRunSpeed = Spark.Property('MaxRunSpeed')

local InputRequest = Spark.Event('InputRequest')

local Players = game:GetService('Players')
local Http = game:GetService('HttpService')

local Assets = RepS.Assets
local GuardAssets = Tree.Find(
    Assets, 
    'Melee/Blight/Block/Guard'
)

local WeaponName = GetPath(
    ServerS.Abilities, 
    script.Parent.Parent, 
    true
)

local Guard = {
    Status = AbilityStatus.Open,
    EffectPaths = {
        Guard = 'Blight/Guard'
    },
    AbilityPaths = {
        'Blight/Block'
    }
}

function Guard.Start(Battle, Ability, PlayerData)
    local Character = Battle.Character
    local Player = Players:GetPlayerFromCharacter(Character)
    local Humanoid = Character:FindFirstChild('Humanoid')
    local WeaponGrip = Character:FindFirstChild('WeaponGrip')

    Battle.Status:Set(AbilityStatus.Low)

    local ContextId = Http:GenerateGUID(false)
    PlayerData.ContextId = ContextId

    Battle:Trigger(
        'Blight/Block',
        'Start',
        PlayerData
    )

    --> Guard Visuals
    local GuardEffect = Guard.Effects.Guard.new(
        Character,
        PlayerData
    )
    GuardEffect:Start(Players:GetChildren())
    Ability.Trove:Add(GuardEffect, 'Destroy')

    --> Guard Animation
    local guardAnim = GuardAssets.GuardAnim
    local guardTrack = Humanoid:LoadAnimation(guardAnim)
    guardTrack:Play()
    Ability.Trove:Add(function()
        guardTrack:Stop(.3)
    end)
    
    --> Slow The Player Down
    if Player then
        MaxRunSpeed:SetFor(Player, 15)

        Ability.Trove:Add(function()
            MaxRunSpeed:SetFor(Player, 20)
        end)
    end

    Ability.Trove:Connect(InputRequest.Fired, function(player, context)
        if Character == player.Character and
            context == ContextId
        then
            Ability.Trove:Clean()
        end
    end)

    Ability.Trove:Add(function()
        Battle.Status:Set(AbilityStatus.Open)
     
        Battle:Trigger(
            'Blight/Block',
            'Destroy',
            PlayerData
        )
    end)

    if PlayerData.Cancelled then
        Ability.Trove:Clean()
    end
end

return Guard