function love.conf(t)
	t.window.title = "Turtle: Invaders"
	t.identity = "Turtle Invaders"
	t.externalstorage = true
	t.window.highdpi = false
	t.window.width = 400
	t.window.height = 240
	t.window.display = 0

	if love._os == "iOS" then
		t.window.highdpi = true
	end
end