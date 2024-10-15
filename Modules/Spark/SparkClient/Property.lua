local RepS = game:GetService('ReplicatedStorage')
local Modules = RepS.Modules
local Value = require(Modules.Value)

local Packages = RepS.Packages
local Trove = require(Packages.Trove)
local Signal = require(Packages.Signal)

local Property = {}
Property.__index = Property

function Property.new(Event, initial)
    local self = setmetatable({}, Property)

    self.Trove = Trove.new()

    self.Value = Value.new()
    self.Trove:Connect(Event.Fired, function(newVal)
        self.Value:Set(newVal)
    end)
    Event:Fire()

    self.Changed = Signal.new()
    self.Trove:Connect(self.Value.Changed, function(oldValue, newValue)
        self.Changed:Fire(oldValue == '___' and nil or oldValue, newValue)
    end)

    self.Value:Set(initial)

    return self
end

function Property:Get()
    return self.Value:Get()
end

function Property:Destroy()
    self.Trove:Clean()
end

function Property:Set(value)
    --[[
        This is only recommended
        for values that are meant
        to be simulated on client with
        server intervention
    ]]
        
    self.Value:Set(value)
end

return Property