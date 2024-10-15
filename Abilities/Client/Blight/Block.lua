local Players = game:GetService('Players')
local RepS = game:GetService('ReplicatedStorage')
local Packages = RepS.Packages
local Trove = require(Packages.Trove)

local Abilities = RepS.Abilities
local RunS = game:GetService('RunService')

local Modules = RepS.Modules
local Spark = require(Modules.Spark)
local InputRequest = Spark.Event('InputRequest')

local CAS = game:GetService('ContextActionService')

local Guard = {}
Guard.__index = Guard

function Guard.new(Character, PlayerData)
    local self = setmetatable({}, Guard)

    self.Character = Character
    self.Root = Character:FindFirstChild('HumanoidRootPart')
    self.Humanoid = Character:FindFirstChild('Humanoid')
    self.Player = Players:GetPlayerFromCharacter(Character)
    self.PlayerData = PlayerData
    self.Trove = Trove.new()

    local Components = RepS.Components
    if self.Player then
        self.Camera = require(
            Components.Camera
        ):GetAll()[1]
    end

    return self
end

function Guard:Start()
    local UIS = game:GetService('UserInputService')
    local BlockDown = UIS:IsKeyDown(Enum.KeyCode.F)

    if not BlockDown then
        InputRequest:Fire(self.PlayerData.ContextId)
    end

    CAS:BindAction('GuardCancel', function(actionName, inputState)
        if actionName == 'GuardCancel' and
            inputState == Enum.UserInputState.End
        then
            InputRequest:Fire(self.PlayerData.ContextId)
        end
    end, false, Enum.KeyCode.F)

    self.Trove:Add(function()
        CAS:UnbindAction('GuardCancel')
    end)
end

return Guard