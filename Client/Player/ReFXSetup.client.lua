local RepS = game:GetService('ReplicatedStorage')
local Packages = RepS.Packages
local ReFX = require(Packages.ReFX)

local Visuals = RepS.Visuals

ReFX.Register(Visuals)
ReFX:Start()