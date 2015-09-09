function love.conf(t)
	t.identity = "TurtleInvaders"
	t.author = "Tiny Turtle Industries"
	t.version = "0.9.2"
	t.console = false
	t.window.vsync = true
	t.window.title = "Turtle: Invaders"
	t.window.width = 600
    t.window.height = 300

    if t.android then
    	t.android.save_storage = "external"
    end
    
    t.modules.physics = false
end
