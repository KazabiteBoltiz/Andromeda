local Block = {
    StartMove = 'Parry'
}

local WeaponPath = 'Blight'

function Block.Trigger(Battle, PlayerData)
    local ActiveWeapon = Battle.ActiveWeapon
    if ActiveWeapon and ActiveWeapon.Name == WeaponPath then
        return true
    end
    return false
end

return Block