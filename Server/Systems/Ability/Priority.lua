local RepS = game:GetService('ReplicatedStorage')
local Packages = RepS.Packages

local EnumList = require(Packages.EnumList)

--[[ 

    "Priority" comes into action when
    an enemy attacks the player who
    is also performing an ability...
    
    ...to decide which fighter's ability
    is cancelled and who is allowed
    to continue.

    The fighter whose ability has the
    lower priority gets their
    ability interrupted and cancelled.
    The one with the higher priority
    continues.

]]

return EnumList.new('AbilityPriority', {
    'Ultimate',
    'Guardbreak',
    'Heavy',
    'Light',
    'Passive',
    'None'
})
