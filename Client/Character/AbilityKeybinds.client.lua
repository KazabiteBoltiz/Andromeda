local RepS = game:GetService('ReplicatedStorage')
local Modules = RepS.Modules
local Spark = require(Modules.Spark)

local CAS = game:GetService('ContextActionService')

local AbilityRequest = Spark.Event('AbilityRequest')

local Keybinds = {
    [Enum.KeyCode.Q] = 'FlashStep',
    [Enum.KeyCode.E] = 'Blight/Equip',
    [Enum.UserInputType.MouseButton1] = 'Blight/Light',
    [Enum.KeyCode.F] = 'Blight/Block'
}

local Character = script.Parent
local Root = Character:WaitForChild('HumanoidRootPart')
local Humanoid = Character:WaitForChild('Humanoid')

local function GetCharacterData()
    return {
        BodyLook = Root.CFrame.LookVector * Vector3.new(1,0,1),
        MoveDirection = Humanoid.MoveDirection
    }
end

local function SetupKeybinds()
    for abilityInput, abilityPath in Keybinds do
        CAS:BindAction(
            abilityPath,
            function(actionName, input)
                if actionName == abilityPath 
                    and input == Enum.UserInputState.Begin
                then
                    AbilityRequest:Fire(
                        abilityPath, 
                        GetCharacterData()
                    )
                end
            end,
            false,
            abilityInput
        )
    end
end

SetupKeybinds()