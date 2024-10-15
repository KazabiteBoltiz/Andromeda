local RepS = game:GetService('ReplicatedStorage')
local Modules = RepS.Modules
local Value = require(Modules.Value)

local Packages = RepS.Packages
local Trove = require(Packages.Trove)
local Signal = require(Packages.Signal)

local Event = {}
Event.__index = Event

function Event.new(instance)
	local self = setmetatable({}, Event)
	
	self.Name = instance.Name
	self.Inst = Value.new()
    self.Fired = Signal.new()
    
    local InstTrove = Trove.new()
    self.Inst.Changed:Connect(function(oldRem, newRem)
        InstTrove:Clean()
        if newRem then
            InstTrove:Connect(newRem.OnClientEvent, function(...)
                self.Fired:Fire(...)
            end)
        end
    end)

    self.Inst:Set(instance)
	
	return self
end

function Event:Fire(...)
    local myRemote = self.Inst:Get()

    if not myRemote then return end
	myRemote:FireServer(...)
end

function Event:Destroy()
    self.Inst:Set()
end

return Event