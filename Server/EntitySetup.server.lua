local ServerS = game:GetService('ServerScriptService')
local Systems = ServerS.Systems
local Battle = require(Systems.Battle)

local CollectionS = game:GetService('CollectionService')

local function onEntityAdded(entity)
    local newBattleInstance = Battle.new(
        entity,
        {}
    )

    print(`Created new <Entity> ({entity})!`)
end

for _, entity in CollectionS:GetTagged('Entity') do
    onEntityAdded(entity)
end

local entityAdded = CollectionS:GetInstanceAddedSignal('Entity')
local entityRemoved = CollectionS:GetInstanceRemovedSignal('Entity')

entityAdded:Connect(onEntityAdded)
entityRemoved:Connect(function(dyingEntity)
    local dyingBattle = Battle.Get(dyingEntity)
    if not dyingBattle then return end

    dyingBattle:Destroy()

    print(`Destroyed <Entity> ({dyingEntity}).`)
end)