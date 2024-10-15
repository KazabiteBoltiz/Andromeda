local RepS = game:GetService('ReplicatedStorage')
local SparkFolder = RepS:WaitForChild('SparkFolder')
local SparkFunctions = SparkFolder:WaitForChild('Functions')

local Packages = RepS.Packages
local Signal = require(Packages.Signal)

local Function = {}
Function.__index = Function

function Function.new(name)
	local self = setmetatable({}, Function)
	
    self.Invoked = Signal.new()
    self.Inst = Instance.new('RemoteFunction')
    self.Inst.Parent = SparkFunctions
    self.Inst.Name = name

    self.OnInvoke = function() end

    self.Inst.OnServerInvoke = function(...)
        return self.OnInvoke(...)
    end

    return self
end

function Function:Destroy()
	self.Inst:Destroy()
end

return Function