local Light = {
    StartMove = 'Charge'
}

local WeaponPath = 'Blight'

function Light.Trigger(Battle, PlayerData)
    local ActiveWeapon = Battle.ActiveWeapon
    if ActiveWeapon and ActiveWeapon.Name == WeaponPath then
        --> Check cooldowns or whatever
        return true
    end
    return false
end

return Light