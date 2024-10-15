local HttpService = game:GetService('HttpService')
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ServerS = game:GetService('ServerScriptService')
local Systems = ServerS.Systems
local Ability = Systems.Ability
local Battle = require(Systems.Battle)
local AbilityStatus = require(Ability.Status)
local AbilityPriority = require(Ability.Priority)

local RepS = game:GetService('ReplicatedStorage')
local Packages = RepS.Packages
local Tree = require(Packages.Tree)
local Assets = RepS.Assets

local Modules = RepS.Modules
local MHitbox = require(Modules.MuchachoHitbox)
local Spark = require(Modules.Spark)
local MaxRunSpeed = Spark.Property('MaxRunSpeed', 20)
local HitboxEvent = Spark.Event('HitboxRequest')

local Http = game:GetService('HttpService')

local Swing = {
    Status = AbilityStatus.Open,
    EffectPaths = {Light = 'Blight/Light', LightHit = 'Blight/LightHit'},
    AbilityPaths = {'Blight/Swing'}
}

function Swing.Start(Battle, Ability, _)
    Battle.Status:Set(AbilityStatus.Locked)

    local Character = Battle.Character
    local Root = Character:FindFirstChild('HumanoidRootPart')
    local Player = Players:GetPlayerFromCharacter(Character)
    local Humanoid = Character:FindFirstChild('Humanoid')

    local ActiveWeapon = Battle.ActiveWeapon
    local Combo = ActiveWeapon.Combo

    local contextId = HttpService:GenerateGUID(false)

    local PlayerData = {}
    PlayerData.Combo = Combo
    PlayerData.ContextId = contextId

    if Player then
        MaxRunSpeed:SetFor(
            Player,
            5
        )
    end

    --> Hitbox Setup
    local HitboxParams = OverlapParams.new()
    HitboxParams.FilterDescendantsInstances = {Character}
    HitboxParams.FilterType = Enum.RaycastFilterType.Exclude

    --> idk why im doing client-side here :P
    Battle:Trigger(
        'Blight/Swing',
        'Start',
        PlayerData
    )

    --> Swing Animation
    local SwingAssets = Tree.Find(
        Assets, 
        'Melee/Blight/Light'
    )
    local SwingAnims = SwingAssets.Animations
    local SwingAnim = SwingAnims['Slash'..Combo]
    local SwingTrack = Humanoid:LoadAnimation(SwingAnim)
    Ability.Trove:Add(SwingTrack)
    SwingTrack:Play(0)
    local SwingSpeed = Combo == 3 and 1.4 or 1.2
    SwingTrack:AdjustSpeed(SwingSpeed)

    local function HitStop()
        SwingTrack:AdjustSpeed(0)
        task.wait(.1)
        SwingTrack.TimePosition += (SwingSpeed * .03)
        SwingTrack:AdjustSpeed(SwingSpeed)
    end

    local Position = Root.Position
    local LookDirection = Root.CFrame.LookVector

    local function HitTargets(targets)
    end

    local HitboxTrove = Ability.Trove:Extend()
    local HitboxMarker = SwingTrack:GetMarkerReachedSignal('Hitbox')

    local HitTargets = {}
    
    HitboxTrove:Connect(HitboxEvent.Fired, function(player, contextId2, targets)
        local Character2 = player.Character
        if Character2 == Character
            and contextId2 == contextId
        then
            HitTargets = targets
            HitboxTrove:Clean()
        end
    end)

    Ability.Trove:Connect(HitboxMarker, function()
        if #HitTargets > 0 then
            HitStop()

            for _, hitTarget in HitTargets do
                local targetBattle = Battle.Get(hitTarget.Parent)
                if not targetBattle then continue end

                local targetPriority = targetBattle.Priority:Get()
                if targetPriority.Value < AbilityPriority.None.Value then
                    continue
                end

                --> Hit Effect
                local HitEffect = Swing.Effects.LightHit.new(
                    hitTarget,
                    PlayerData
                )
                HitEffect:Start(Players:GetChildren())

                --> Sending Target Knockback
                targetBattle:Activate(
                    'Knockback'
                )
            end
        end
    end)

    ActiveWeapon.SwingTrack = SwingTrack

    local CraterEffect = Swing.Effects.Light.new(
        Character,
        PlayerData
    )
    CraterEffect:Start(Players:GetChildren())

    --> Stop Client-Side
    Ability.Trove:Add(function()
        Battle:Trigger(
            'Blight/Swing',
            'Destroy',
            PlayerData
        )
    end)

    Ability.Trove:Add(function()
        if Player then
            MaxRunSpeed:SetFor(
                Player,
                20
            )
        end
    end)

    --> Unlock Battle State
    Ability.Trove:Add(task.delay(Combo < 3 and .2 or .4, function()
        Battle.Status:Set(AbilityStatus.Open)

        --> Update Combo
        local comboNow = Battle.ActiveWeapon.Combo + 1
        if comboNow > 3 then
            comboNow = 1
        end
        Battle.ActiveWeapon.Combo = comboNow
    end))

    --> End Delay
    Ability.Trove:Add(task.delay(Combo < 3 and .2 or .4, function()
        Ability.Trove:Clean()
    end))
end

return Swing