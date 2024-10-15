local RunS = game:GetService('RunService')
if RunS:IsClient() then return {} end

local RepS = game:GetService('ReplicatedStorage')

local SparkFolder = Instance.new('Folder')
SparkFolder.Name = 'SparkFolder'
SparkFolder.Parent = RepS

local Events = Instance.new('Folder')
Events.Name = 'Events'
Events.Parent = SparkFolder

local Functions = Instance.new('Folder')
Functions.Name = 'Functions'
Functions.Parent  = SparkFolder

local Event = require(script.Event)
local Function = require(script.Function)
local Property = require(script.Property)

local SparkServer = {
	Events = {},
	Functions = {},
	Properties = {}
}

Events.ChildRemoved:Connect(function(remote)
	SparkServer.Events[remote.Name] = nil
end)

Functions.ChildRemoved:Connect(function(remote)
	SparkServer.Functions[remote.Name] = nil
end)

function SparkServer.Event(name)
	--[[ 
		Look for event object.
		If exists, return the object.
		If doesn't exist, create one.
	]]
	
	if SparkServer.Events[name] then
		return SparkServer.Events[name]
	end
	
	local newEventObject = Event.new(name)
	SparkServer.Events[name] = newEventObject

	return newEventObject
end

function SparkServer.Function(name)
	if SparkServer.Functions[name] then
		return SparkServer.Functions[name]
	end
	
	local newFunctionObject = Function.new(name)
	SparkServer.Functions[name] = newFunctionObject

	return newFunctionObject
end

function SparkServer.Property(path, initialValue)
	local existingProperty = SparkServer.Properties[path]
	if not existingProperty then
		local newEvent = SparkServer.Event(path..'_PROPERTY')

		local newProperty = Property.new(path, initialValue, newEvent)
		SparkServer.Properties[path] = newProperty

		return newProperty
	end

	return existingProperty
end

return SparkServer