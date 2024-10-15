local RunS = game:GetService('RunService')

if RunS:IsClient() then
	return require(script.SparkClient)
else
	return require(script.SparkServer)
end