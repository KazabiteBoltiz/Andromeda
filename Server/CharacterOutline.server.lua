local RepS = game:GetService('ReplicatedStorage')
local Assets = RepS.Assets
local OutlineModel = Assets.Basic.Outline

game.Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function(c)
		local outline = OutlineModel:Clone(); outline.Parent = c; outline:SetPrimaryPartCFrame(c.Torso.CFrame)
		for _,v in pairs(outline:GetChildren()) do
			v.WeldConstraint.Part1 = c[v.Name]
		end
	end)
end)
