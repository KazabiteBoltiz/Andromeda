local RepS = game:GetService('ReplicatedStorage')
local SparkFolder = RepS:WaitForChild('SparkFolder')
local Events = SparkFolder:WaitForChild('Events')
local Functions = SparkFolder:WaitForChild('Functions')

local Packages = RepS.Packages
local Promise = require(Packages.Promise)

local Event = require(script.Event)
local Function = require(script.Function)
local Property = require(script.Property)

local FakeEvents = {}
local FakeFunctions = {}

local SparkClient = {
	Events = {},
	Functions = {},
	Properties = {}
}

local function GetExistingRemote(folder, remoteName)
	return Promise.new(function(resolve, reject)
		local existingRemote = folder:FindFirstChild(remoteName)
		if existingRemote then
			resolve(existingRemote)
		else
			reject()
		end
	end)
end

local function OnRemoteAdded(remote)
	local name = remote.name

	local isEvent = remote:IsA('RemoteEvent')
	local remoteFolder = isEvent and 'Events' or 'Functions'
	local fakeFolder = isEvent and FakeEvents or FakeFunctions

	local existingEvent = SparkClient[remoteFolder][name]
	if existingEvent then
		if existingEvent.IsFake then
			--> If A Fake Event Was Created Before
			--> Replace With Real Event Of Same Name
			existingEvent.IsFake = false
			existingEvent.Inst:Set(remote)
			fakeFolder[name] = nil
		else
			return SparkClient[remoteFolder][name]
		end
	end

	local newEvent = isEvent and Event.new(remote) or Function.new(remote)
	SparkClient[remoteFolder][name] = newEvent
	return newEvent
end

local function OnRemoteRemoved(remote)
	local name = remote.Name

	local isEvent = remote:IsA('RemoteEvent')
	local remoteFolder = isEvent and 'Events' or 'Functions'
	local fakeFolder = isEvent and FakeEvents or FakeFunctions

	SparkClient[remoteFolder][name]:Destroy()

	--> Below should never happen,
	--> But just in case it does...
	if fakeFolder[name] then
		fakeFolder[name]:Destroy()
	end

	--> Detecting For Property Events
	if isEvent then
		local splitPath = string.split(name, '_')
		local isProperty = splitPath[2] == 'PROPERTY'
		if isProperty then
			local property = SparkClient.Properties[splitPath[1]]
			property:Destroy()
			SparkClient.Properties[splitPath[1]] = nil
		end
	end
end

function SparkClient.Event(name)
	if SparkClient.Events[name] then
		return SparkClient.Events[name]
	end

	--> Creating A Fake Event
	local FakeRemote = Instance.new('RemoteEvent')
	FakeRemote.Name = name..'FAKE'
	FakeEvents[name] = Event.new(
		FakeRemote
	)
	FakeEvents[name].IsFake = true

	--> Storing The Fake Event
	SparkClient.Events[name] = FakeEvents[name]

	return FakeEvents[name]
end

function SparkClient.Function(name)
	if SparkClient.Functions[name] then
		return SparkClient.Functions[name]
	end

	--> Creating A Fake Function
	local FakeRemote = Instance.new('RemoteFunction')
	FakeRemote.Name = name..'FAKE'
	FakeFunctions[name] = Function.new(
		FakeRemote
	)
	FakeFunctions[name].IsFake = true

	--> Storing The Fake Function
	SparkClient.Functions[name] = FakeFunctions[name]

	return FakeFunctions[name]
end

function SparkClient.Property(path, initial)
	local existingProperty = SparkClient.Properties[path]
	if existingProperty then
		return existingProperty
	end

	local propertyEvent = SparkClient.Event(path..'_PROPERTY')
	local newProperty = Property.new(propertyEvent, initial)
	SparkClient.Properties[path] = newProperty

	return newProperty
end

--> Event Loading
Events.ChildAdded:Connect(OnRemoteAdded)
Events.ChildRemoved:Connect(OnRemoteRemoved)
for _, remote in Events:GetChildren() do
	OnRemoteAdded(remote)
end

--> Function Loading
Functions.ChildAdded:Connect(OnRemoteAdded)
Functions.ChildRemoved:Connect(OnRemoteRemoved)
for _, remote in Functions:GetChildren() do
	OnRemoteAdded(remote)
end

return SparkClient