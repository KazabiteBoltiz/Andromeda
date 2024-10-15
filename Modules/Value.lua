local RepS = game:GetService('ReplicatedStorage')
local Packages = RepS.Packages
local Signal = require(Packages.Signal)

--[[===============]]--

local Value = {}
Value.__index = Value

function Value.new(initialValue)
    local self = setmetatable({}, Value)

    self.oldValue = initialValue

    self.Changed = Signal.new()
    self.SetTo = Signal.new()

    return self
end

function Value:Get()
    return self.oldValue
end

function Value:Set(newValue)
    local isTable = false

    if typeof(newValue) == 'table'
        or typeof(self.oldValue) == 'table'
    then
        isTable = true
    end

    self.SetTo:Fire(self.oldValue, newValue)

    if isTable or (newValue ~= self.oldValue) then
        local cachedOldValue = self.oldValue
        self.oldValue = newValue
        
        self.Changed:Fire(cachedOldValue, newValue)
    end
end

return Value