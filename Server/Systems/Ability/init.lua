local RepS = game:GetService('ReplicatedStorage')
local Modules = RepS.Modules
local Value = require(Modules.Value)

local Visuals = RepS.Visuals

local Packages = RepS.Packages
local Tree = require(Packages.Tree)

local Status = require(script.Status)

--[[====================]]--

local ServerS = game:GetService('ServerScriptService')
local Abilities = ServerS.Abilities
local ClientAbilities = RepS.Abilities

local function GetPath(folderNow, resultPath)
	if resultPath == nil then resultPath = {folderNow.Name} end
	if folderNow == Abilities then return resultPath end

	local parentOfFolder = folderNow.Parent

	if parentOfFolder then
		table.insert(resultPath, parentOfFolder.Name)
		return GetPath(parentOfFolder, resultPath)
	end
end

--[[====================]]--

local Ability = {}
Ability.__index = Ability

function Ability.new(Battle, PlayerData, MoveContainer, StartMove)
	local self = setmetatable({}, Ability)

	self.Path = GetPath(MoveContainer)

	self.Battle = Battle
	self.Trove = Battle.Trove:Extend()

	self.Move = Value.new()
	self.Moves = {}
	for _, moveModule in MoveContainer:GetChildren() do
		self.Moves[moveModule.Name] = require(moveModule)
	end

	self.Move.SetTo:Connect(function(oldMoveName, newMoveName)
		-- print(`[Move] {oldMoveName or nil} -> {newMoveName}`)
	end)

	self:Switch(StartMove, PlayerData)
	
	return self
end

function Ability:Switch(newMoveName, PlayerData)
	local newMove = self.Moves[newMoveName]
	if not newMove then return end

	self.Trove:Clean()

	self.Move:Set(newMoveName)

	local newMoveTask = task.spawn(function()
		if not newMove.Effects then
			newMove.Effects = {}
		end

		for effectName, effectPath in newMove.EffectPaths do
			newMove.Effects[effectName] = require(
				Tree.Find(Visuals, effectPath)
			)
		end

		for abilityName, abilityPath in newMove.AbilityPaths do
			newMove.Effects[abilityName] = require(
				Tree.Find(ClientAbilities, abilityPath)
			)
		end

		newMove.Start(
			self.Battle,
			self,
			PlayerData
		)
	end)
	
	self.Trove:Add(newMoveTask)
end

function Ability:GetPath(moveName)
	local splitAbilityPath = string.split(self.Path, '/')
	table.insert(splitAbilityPath, moveName)
	local completePath = table.concat(splitAbilityPath, '/')
	return completePath
end

function Ability:Complete()
	self.Trove:Clean()
	
	self.Battle:Announce(
		self.Battle.Character,
		self:GetPath(self.Move:Get()),
		'Finished'
	)
end

return Ability
