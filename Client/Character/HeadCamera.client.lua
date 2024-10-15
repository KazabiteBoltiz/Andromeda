local Camera = workspace.CurrentCamera

local Character = script.Parent
local Head = Character:WaitForChild('Head')
local Humanoid = Character:WaitForChild('Humanoid')
local HRP = Character:WaitForChild('HumanoidRootPart')

local TweenS = game:GetService('TweenService')
local RunS = game:GetService('RunService').RenderStepped

RunS:Connect(function()
	TweenS:Create(
		Humanoid,
		TweenInfo.new(.3),
		{
			CameraOffset = (HRP.CFrame+Vector3.new(0,0.5,0)):pointToObjectSpace(Head.CFrame.p)
		}
	):Play()
end)