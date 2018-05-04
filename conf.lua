function love.conf(t)
	t.identity = "Turtle Invaders"
	t.console = true

	if love._version then
		t.window.title = "Turtle: Invaders"
		
		t.window.width = 1280
		t.window.height = 720
	end
end
