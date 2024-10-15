return function(speed, magnitude, delay, exitSpeed, cameraSpring)
	cameraSpring.Speed = speed
	cameraSpring.Target = Vector3.new(magnitude/100,0,0)
	task.wait(delay)
	cameraSpring.Speed = exitSpeed
	cameraSpring.Target = Vector3.new(0,0,0)
end