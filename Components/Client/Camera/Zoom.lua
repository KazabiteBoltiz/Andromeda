return function(speed, magnitude, delay, exitSpeed, _, cameraFOVSpring)
	cameraFOVSpring.Speed = speed
	cameraFOVSpring.Target = magnitude
	task.wait(delay)
	cameraFOVSpring.Speed = exitSpeed
	cameraFOVSpring.Target = 0
end