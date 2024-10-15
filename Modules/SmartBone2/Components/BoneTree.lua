--!nocheck
--!native

local WIND_SEED = 1029410295159813
local WIND_RNG = Random.new(WIND_SEED)
local Lighting = game:GetService("Lighting")
local Dependencies = script.Parent.Parent:WaitForChild("Dependencies")
local BoneClass = require(script.Parent:WaitForChild("Bone"))
local Config = require(Dependencies:WaitForChild("Config"))
local DefaultObjectSettings = require(Dependencies:WaitForChild("DefaultObjectSettings"))
local Gizmo = require(Dependencies:WaitForChild("Gizmo"))
local Utilities = require(Dependencies:WaitForChild("Utilities"))
local MaxVector = Vector3.new(math.huge, math.huge, math.huge)
local IsStudio = game:GetService("RunService"):IsStudio()

if IsStudio or Config.ALLOW_LIVE_GAME_DEBUG then
	Gizmo.Init()
end

local SB_VERBOSE_LOG = Utilities.SB_VERBOSE_LOG

export type IBoneTree = {
	WindOffset: number,
	Root: Bone,
	RootPart: BasePart,
	RootPartSize: Vector3,
	Bones: { BoneClass.IBone },
	Settings: { [string]: any },
	UpdateRate: number,
	AccumulatedDelta: number,
	BoundingBoxCFrame: CFrame,
	BoundingBoxSize: Vector3,

	InView: bool,
	Destroyed: bool,
	IsSkippingUpdates: bool,
	InWorkspace: bool,

	Force: Vector3,
	ObjectMove: Vector3,
	ObjectVelocity: Vector3,
	ObjectAcceleration: Vector3,
	ObjectPreviousPosition: Vector3,
}

type ImOverlay = {
	Begin: (Text: string, BackgroundColor: Color3?, TextColor: Color3?) -> (),
	End: () -> (),
	Text: (Text: string, BackgroundColor: Color3?, TextColor: Color3?) -> (),
}

type bool = boolean

local function SafeUnit(v3: Vector3): Vector3
	if v3.Magnitude == 0 then
		--warn("Vector was saved")
		return Vector3.zero
	end

	return v3.Unit
end

local function map(n: number, start: number, stop: number, newStart: number, newStop: number, withinBounds: bool): number
	local value = ((n - start) / (stop - start)) * (newStop - newStart) + newStart

	--// Returns basic value
	if not withinBounds then
		return value
	end

	--// Returns values constrained to exact range
	if newStart < newStop then
		return (value < newStop and value or newStop) > newStart and (value < newStop and value or newStop) or newStart
	else
		return (value < newStart and value or newStart) > newStop and (value < newStart and value or newStart) or newStop
	end
end

--- @class BoneTree
--- Internal class for all bone trees
--- :::caution Caution:
--- Changes to the syntax in this class will not count to the major version in semver.
--- :::

--- @within BoneTree
--- @readonly
--- @prop WindOffset number
--- Used in wind calculations so each bone tree has a different solution.

--- @within BoneTree
--- @readonly
--- @prop Root Bone
--- Root bone of the bone tree

--- @within BoneTree
--- @readonly
--- @prop RootPart BasePart

--- @within BoneTree
--- @readonly
--- @prop RootPartSize Vector3
--- Constant value of the root parts size at the start of the simulation

--- @within BoneTree
--- @prop Bones table

--- @within BoneTree
--- @prop Settings {}

--- @within BoneTree
--- @readonly
--- @prop UpdateRate number
--- Throttled update rate

--- @within BoneTree
--- @readonly
--- @prop InView boolean

--- @within BoneTree
--- @readonly
--- @prop BoundingBoxCFrame CFrame

--- @within BoneTree
--- @readonly
--- @prop BoundingBoxSize Size

--- @within BoneTree
--- @readonly
--- @prop AccumulatedDelta number
--- Used in the runtime

--- @within BoneTree
--- @readonly
--- @prop Destroyed boolean
--- True if the root part has been destroyed

--- @within BoneTree
--- @readonly
--- @prop IsSkippingUpdates boolean
--- True if the bone tree is currently skipping updates

--- @within BoneTree
--- @readonly
--- @prop InWorkspace boolean
--- Boolean describing if the rootpart is a descendant of workspace

--- @within BoneTree
--- @readonly
--- @prop Force Vector3

--- @within BoneTree
--- @prop ObjectMove Vector3
--- Difference between root parts last position and current position

--- @within BoneTree
--- @prop ObjectVelocity Vector3
--- Velocity at which the root part is traveling at, calculated via object move.

--- @within BoneTree
--- @prop ObjectPreviousPosition Vector3
--- Root parts previous position

local Class = {}
Class.__index = Class

--- @within BoneTree
--- @param RootBone Bone
--- @param RootPart BasePart
--- @return BoneTree
function Class.new(RootBone: Bone, RootPart: BasePart): IBoneTree
	local self = setmetatable({
		WindOffset = WIND_RNG:NextNumber(0, 1e6),
		Root = RootBone:IsA("Bone") and RootBone or nil,
		RootPart = RootPart,
		RootPartSize = RootPart.Size,
		Bones = {},
		Settings = {},
		UpdateRate = 0,
		InView = true,
		AccumulatedDelta = 0,
		BoundingBoxCFrame = RootPart.CFrame,
		BoundingBoxSize = RootPart.Size,

		Destroyed = false,
		IsSkippingUpdates = false,
		InWorkspace = false,

		Force = Vector3.zero,
		ObjectMove = Vector3.zero,
		ObjectVelocity = Vector3.zero,
		ObjectAcceleration = Vector3.zero,
		ObjectPreviousPosition = RootPart.Position,
	}, Class)

	self.InWorkspace = RootPart:IsDescendantOf(workspace)

	-- TODO: Revisit optimising :IsDescendantOf calls
	self.DestroyConnection = RootPart.AncestryChanged:ConnectParallel(function()
		if not RootPart:IsDescendantOf(game) then
			self.Destroyed = true
		end

		self.InWorkspace = RootPart:IsDescendantOf(workspace)
	end)

	self.AttributeConnection = RootPart.AttributeChanged:ConnectParallel(function(Attribute)
		-- No need validating
		self.Settings[Attribute] = RootPart:GetAttribute(Attribute) or DefaultObjectSettings[Attribute]
	end)

	return self :: IBoneTree
end

--- @within BoneTree
--- Called in BoneTree:PreUpdate(),
--- Computes the bounding box of all the bones
function Class:UpdateBoundingBox()
	debug.profilebegin("BoneTree::UpdateBoundingBox")

	if not self.InView then
		self.BoundingBoxCFrame = self.RootPart.CFrame
		self.BoundingBoxSize = self.RootPart.Size

		debug.profileend()
		return
	end

	local BottomCorner = MaxVector
	local TopCorner = -MaxVector

	debug.profilebegin("Max Min Bones")
	for _, Bone in self.Bones do
		debug.profilebegin("Max Min Bone")
		local Velocity = (Bone.Position - Bone.LastPosition)
		local Position = Bone.Position + Velocity

		BottomCorner = BottomCorner:Min(Position)
		TopCorner = TopCorner:Max(Position)
		debug.profileend()
	end
	debug.profileend()

	local CenterOfMass = (BottomCorner + TopCorner) * 0.5

	self.BoundingBoxCFrame = CFrame.new(CenterOfMass)
	self.BoundingBoxSize = self.RootPartSize:Max(TopCorner - BottomCorner)

	debug.profileend()
end

--- @within BoneTree
--- @param RootPosition Vector3 -- Position of the root part (Micro Optimization)
--- Called in BoneTree:PreUpdate()
function Class:UpdateThrottling(RootPosition: Vector3)
	debug.profilebegin("BoneTree::UpdateThrottling")
	local Settings = self.Settings

	local Camera = workspace.CurrentCamera
	local Distance = (RootPosition - Camera.CFrame.Position).Magnitude

	if Distance > Settings.ActivationDistance then
		self.UpdateRate = 0
		debug.profileend()
		return
	end

	local UpdateRate = 1 - map(Distance, Settings.ThrottleDistance, Settings.ActivationDistance, 0, 1, true)
	self.UpdateRate = Settings.UpdateRate * UpdateRate
	debug.profileend()
end

--- @within BoneTree
--- @param Delta number -- Δt
--- Calculates object move, gravity and throttled update rate. Also calls Bone:PreUpdate()
function Class:PreUpdate(Delta: number)
	debug.profilebegin("BoneTree::PreUpdate")
	local RootPartCFrame = self.RootPart.CFrame
	local RootPartPosition = RootPartCFrame.Position

	local PreviousVelocity = self.ObjectVelocity

	self.ObjectMove = (RootPartPosition - self.ObjectPreviousPosition)
	self.ObjectVelocity = self.ObjectMove
	self.ObjectAcceleration = (PreviousVelocity - self.ObjectVelocity)
	self.ObjectPreviousPosition = RootPartPosition
	self.RootPartSize = self.RootPart.Size

	self:UpdateThrottling(RootPartPosition)
	self:UpdateBoundingBox()

	for _, Bone in self.Bones do
		Bone:PreUpdate(self)
	end
	debug.profileend()
end

--- @within BoneTree
--- @param Delta number -- Δt
--- Calculates forces and updates wind. Also calls Bone:StepPhysics()
function Class:StepPhysics(Delta: number)
	debug.profilebegin("BoneTree::StepPhysics")
	local Settings = self.Settings
	local Force = (Settings.Gravity + Settings.Force) * Delta

	if Settings.MatchWorkspaceWind == true then
		local GlobalWind = workspace.GlobalWind
		Settings.WindDirection = SafeUnit(GlobalWind)
		Settings.WindSpeed = GlobalWind.Magnitude
	else
		local WindDirection = Lighting:GetAttribute("WindDirection") or DefaultObjectSettings.WindDirection
		local WindSpeed = Lighting:GetAttribute("WindSpeed") or DefaultObjectSettings.WindSpeed

		Settings.WindDirection = SafeUnit(WindDirection)
		Settings.WindSpeed = WindSpeed
	end

	local WindStrength = Lighting:GetAttribute("WindStrength") or DefaultObjectSettings.WindStrength

	Settings.WindStrength = WindStrength

	for _, Bone in self.Bones do
		Bone:StepPhysics(self, Force, Delta)
	end
	debug.profileend()
end

--- @within BoneTree
--- @param ColliderObjects table
--- @param Delta number -- Δt
function Class:Constrain(ColliderObjects, Delta: number)
	debug.profilebegin("BoneTree::Constrain")
	for _, Bone in self.Bones do
		Bone:Constrain(self, ColliderObjects, Delta)
	end
	debug.profileend()
end

--- @within BoneTree
--- Resets all bones to their rest positions.
function Class:SkipUpdate()
	debug.profilebegin("BoneTree::SkipUpdate")
	for _, Bone in self.Bones do
		Bone:SkipUpdate()
	end

	self.IsSkippingUpdates = true
	debug.profileend()
end

--- @within BoneTree
--- @param Delta number -- Δt
function Class:SolveTransform(Delta: number)
	debug.profilebegin("BoneTree::SolveTransform")
	for _, Bone in self.Bones do
		Bone:SolveTransform(self, Delta)
	end

	self.IsSkippingUpdates = false
	debug.profileend()
end

--- @within BoneTree
--- Applys all the transforms to bones in serial context.
function Class:ApplyTransform()
	debug.profilebegin("BoneTree::ApplyTransform")
	for _, Bone in self.Bones do
		Bone:ApplyTransform(self)
	end
	debug.profileend()
end

--- @client
--- @within BoneTree
--- @param DRAW_CONTACTS boolean
--- @param DRAW_PHYSICAL_BONE boolean
--- @param DRAW_BONE boolean
--- @param DRAW_AXIS_LIMITS boolean
--- @param DRAW_ROOT_PART boolean
--- @param DRAW_BOUNDING_BOX boolean
--- @param DRAW_ROTATION_LIMITS boolean
--- @param DRAW_ACCELERATION_INFO boolean
function Class:DrawDebug(
	DRAW_CONTACTS: bool,
	DRAW_PHYSICAL_BONE: bool,
	DRAW_BONE: bool,
	DRAW_AXIS_LIMITS: bool,
	DRAW_ROOT_PART: bool,
	DRAW_BOUNDING_BOX: bool,
	DRAW_ROTATION_LIMITS: bool,
	DRAW_ACCELERATION_INFO: bool
)
	debug.profilebegin("BoneTree::DrawDebug")
	local LINE_CONNECTING_COLOR = Color3.fromRGB(248, 168, 20)
	local ROOT_PART_BOUNDING_BOX_COLOR = Color3.fromRGB(76, 208, 223)
	local ROOT_PART_FILL_COLOR = Color3.fromRGB(255, 89, 89)
	local OBJECT_MOVE_COLOR = Color3.new(1, 0, 0)
	local OBJECT_VELOCITY_COLOR = Color3.new(0, 1, 0)
	local OBJECT_ACCELERATION_COLOR = Color3.new(0, 0, 1)

	if DRAW_ACCELERATION_INFO then
		local Raised = self.RootPart.Position + Vector3.new(0, self.RootPart.Size.Y * 0.5 + 1, 0)

		Gizmo.SetStyle(OBJECT_MOVE_COLOR, 0, true)
		Gizmo.Arrow:Draw(Raised, Raised + self.ObjectMove, 0.025, 0.1, 6)

		Gizmo.SetStyle(OBJECT_VELOCITY_COLOR, 0, true)
		Gizmo.Arrow:Draw(Raised, Raised + self.ObjectVelocity, 0.025, 0.1, 6)

		Gizmo.SetStyle(OBJECT_ACCELERATION_COLOR, 0, true)
		Gizmo.Arrow:Draw(Raised, Raised + self.ObjectAcceleration, 0.025, 0.1, 6)
	end

	Gizmo.PushProperty("AlwaysOnTop", false)

	if DRAW_BOUNDING_BOX then
		Gizmo.PushProperty("Color3", ROOT_PART_BOUNDING_BOX_COLOR)
		Gizmo.Box:Draw(self.BoundingBoxCFrame, self.BoundingBoxSize, true)
	end

	if DRAW_ROOT_PART then
		Gizmo.PushProperty("Color3", ROOT_PART_BOUNDING_BOX_COLOR)
		Gizmo.Box:Draw(self.RootPart.CFrame, self.RootPart.Size, true)

		Gizmo.SetStyle(ROOT_PART_FILL_COLOR, 0.75, false)
		Gizmo.VolumeBox:Draw(self.RootPart.CFrame, self.RootPart.Size)

		Gizmo.PushProperty("Transparency", 0)
	end

	for i, Bone in self.Bones do
		local BonePosition = Bone.Bone.TransformedWorldCFrame.Position
		local ParentBone = self.Bones[Bone.ParentIndex]

		Bone:DrawDebug(self, DRAW_CONTACTS, DRAW_PHYSICAL_BONE, DRAW_BONE, DRAW_AXIS_LIMITS, DRAW_ROTATION_LIMITS)

		if DRAW_PHYSICAL_BONE and i ~= 1 then
			Gizmo.PushProperty("Color3", LINE_CONNECTING_COLOR)
			Gizmo.Ray:Draw(ParentBone.Bone.TransformedWorldCFrame.Position, BonePosition)
		end
	end
	debug.profileend()
end

--- @client
--- @within SmartBone
--- @param Overlay ImOverlay
function Class:DrawOverlay(Overlay: ImOverlay)
	if Config.DEBUG_OVERLAY_TREE_INFO or Config.DEBUG_OVERLAY_TREE_OBJECTS then
		Overlay.Text(`Root Part: {self.RootPart.Name}`)
		Overlay.Text(`Root Bone: {self.Root.Name}`)
		Overlay.Text(`Root Part Size: {string.format("%.3f, %.3f, %.3f", self.RootPart.Size.X, self.RootPart.Size.Y, self.RootPart.Size.Z)}`)
	end

	if Config.DEBUG_OVERLAY_TREE_INFO or Config.DEBUG_OVERLAY_TREE_NUMERICS then
		Overlay.Text(`Update Rate: {string.format("%.3f", self.UpdateRate)}`)
		Overlay.Text(`In View: {self.InView}`)
		Overlay.Text(`Accumulated Delta: {string.format("%.3f", self.AccumulatedDelta)}`)
		Overlay.Text(`Force: {string.format("%.3f, %.3f, %.3f", self.Force.X, self.Force.Y, self.Force.Z)}`)
	end

	local ROOT_BACKGROUND_COLOR = Color3.new(0.486275, 0.431373, 1.000000)
	local ROOT_TEXT_COLOR = Color3.new(1, 1, 1)

	if Config.DEBUG_OVERLAY_BONE then
		for i, Bone in self.Bones do
			if Config.DEBUG_OVERLAY_MAX_BONES > 0 then
				if Config.DEBUG_OVERLAY_BONE_OFFSET + Config.DEBUG_OVERLAY_MAX_BONES <= i then
					break
				end
			end

			if Config.DEBUG_OVERLAY_BONE_OFFSET > i then
				continue
			end

			Overlay.Begin(`Bone {i}`, ROOT_BACKGROUND_COLOR, ROOT_TEXT_COLOR)
			Bone:DrawOverlay(Overlay)
			Overlay.End()
		end
	end
end

function Class:Destroy()
	SB_VERBOSE_LOG("Destroy BoneTree")

	task.synchronize()
	self.DestroyConnection:Disconnect()
	self.AttributeConnection:Disconnect()

	for _, Bone in self.Bones do
		Bone:Destroy()
	end

	setmetatable(self, nil)
	task.desynchronize()
end

return Class
