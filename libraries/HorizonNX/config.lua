local CONFIG = {}

--Username
CONFIG.USERNAME = "LOVE2D"

--Keyboard bindings
CONFIG.KEYS =
{
	a = "z",
	b = "x",
	y = "c",
	x = "v",

	plus = "return",
	minux = "rshift",

	l = "q",
	r = "u",

	lz = "e",
	rz = "o",

	dpup = "up",
	dpleft = "left",
	dpdown = "down",
	dpright = "right",

	leftAxis =
	{
		y = {"w", "s"},
		x = {"a", "d"}
	},

	rightAxis =
	{
		y = {"u", "j"},
		x = {"h", "k"}
	}
}

return CONFIG