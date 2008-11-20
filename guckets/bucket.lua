module("guckets.bucket", package.seeall)

function new(self)
	o = {}
	setmetatable(o, { __index = self })
	return o
end

-- set water. returns the amount of water that did not fit
function set_water(self, v)
	self.water = v
	if (self.water > self.water_max) then
		self.water = self.water_max
		return v - self.water_max
	else
		return 0
	end
end

function get_water(self)
	return self.water
end

function set_water_max(self, m)
	self.water_max = m
end

function get_water_max(self)
	return self.water_max
end

function pour_to(self, target)
	self.water = target:set_water(target.water + self.water)
end
