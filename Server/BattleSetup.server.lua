local ServerS = game:GetService('ServerScriptService')
local Systems = ServerS.Systems
local Battle = require(Systems.Battle)

local RepS = game:GetService('ReplicatedStorage')
local Modules = RepS.Modules
local Spark = require(Modules.Spark)

--[[====================]]--

local Players = game:GetService('Players')

local function OnPlayerJoin(player)
    player.CharacterAdded:Connect(function(character)
        local newBattle = Battle.new(
            character,
            {
                'FlashStep',
                'Blight/Equip',
                'Blight/Light',
                'Blight/Block'
            }
        )
    end)

    player.CharacterRemoving:Connect(function(character)
        
    end)
end

Players.PlayerAdded:Connect(OnPlayerJoin)

--[[====================]]--

local AbilityRequest = Spark.Event('AbilityRequest')
AbilityRequest.Fired:Connect(function(player, abilityPath, playerData)
    local battleInstance = Battle.Get(player)
    if not battleInstance then return end

    battleInstance:Activate(abilityPath, playerData)
end)