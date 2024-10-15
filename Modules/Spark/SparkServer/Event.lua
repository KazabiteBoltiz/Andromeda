local RepS = game:GetService('ReplicatedStorage')
local SparkFolder = RepS:WaitForChild('SparkFolder')
local SparkEvents = SparkFolder:WaitForChild('Events')

local Packages = RepS.Packages
local Signal = require(Packages.Signal)

local Event = {}
Event.__index = Event

function Event.new(name)
	local self = setmetatable({}, Event)
	
	self.Name = name
	
	local myInst = Instance.new('RemoteEvent')
	myInst.Name = name
	myInst.Parent = SparkEvents
	self.Inst = myInst
    self.Fired = Signal.new()

    self.Inst.OnServerEvent:Connect(function(...)
        self.Fired:Fire(...)
    end)

	return self
end

function Event:Fire(player, ...)
    if not self.Inst then return end
	self.Inst:FireClient(player, ...)
end

function Event:FireAll(...)
    if not self.Inst then return end
    self.Inst:FireAllClients(...)
end

function Event:Destroy()
	self.Inst:Destroy()
end

return Event