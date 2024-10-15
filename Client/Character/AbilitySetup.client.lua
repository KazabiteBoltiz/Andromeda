local RepS = game:GetService('ReplicatedStorage')
local Modules = RepS.Modules
local Spark = require(Modules.Spark)

local Packages = RepS.Packages
local Tree = require(Packages.Tree)

local ClientAbilities = RepS.Abilities

local AbilityRequest = Spark.Event('AbilityRequest')

local AbilityInstances = {}

local function onAbility(AbilityPath, State, ...)
    local doesModuleExist = Tree.Exists(
        ClientAbilities,
        AbilityPath
    )
    
    if not doesModuleExist then return end

    local abilityModule = require(
        Tree.Find(ClientAbilities, AbilityPath)
    )

    if State == 'Start' then
        local newInstance = abilityModule.new(script.Parent, ...)
        AbilityInstances[AbilityPath] = newInstance
        newInstance:Start()
    elseif State == 'Destroy' then
        local existingInstance = AbilityInstances[AbilityPath]
        if existingInstance then
            existingInstance.Trove:Clean()
        end
    else
        local existingInstance = AbilityInstances[AbilityPath]
        if existingInstance then
            existingInstance[State](existingInstance, ...)
        end
    end
end

AbilityRequest.Fired:Connect(onAbility)