local RepS = game:GetService('ReplicatedStorage')
local SparkFolder = RepS:WaitForChild('SparkFolder')
local SparkFunctions = SparkFolder:WaitForChild('Functions')

local Modules = RepS.Modules
local Value = require(Modules.Value)

local Packages = RepS.Packages
local Trove = require(Packages.Trove)
local Signal = require(Packages.Signal)

local Function = {}
Function.__index = Function

function Function.new(instance)
	local self = setmetatable({}, Function)
	
    self.Inst = Value.new()
    self.Received = Signal.new()

    self.Inst:Set(instance)

    return self
end

function Function:Invoke(...)
    local Remote = self.Inst:Get()
    if not Remote or self.IsFake then return end
    local value = Remote:InvokeServer(...)
    self.Received:Fire(value)
    return value
end

function Function:Destroy()
    self.Inst:Set()
end

return Function