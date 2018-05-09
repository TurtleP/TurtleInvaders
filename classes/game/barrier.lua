barrier = class("barrier", entity)

function barrier:initialize(x)
	entity.initialize(self, x, 0, 1, WINDOW_HEIGHT)

	self.mask = { false }

	self.category = 1

	self.static = true
end