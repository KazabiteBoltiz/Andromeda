local RepS = game:GetService('ReplicatedStorage')
local Packages = RepS.Packages

local EnumList = require(Packages.EnumList)

--[[

    "Status" comes into play when
    the same fighter tries to 
    activate additional abilities
    while already performing one.

    If the active ability of the
    player has a lower status than
    the ability they want to activate,

    the active ability is cancelled
    and the new one is activated.
    
]]

return EnumList.new('AbilityStatus', {
    'Open',
    'Low',
    'Standard',
    'High',
    'Locked'
})
