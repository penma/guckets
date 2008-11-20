module("guckets.bucket", package.seeall)

function new(self)
	o = {}
	setmetatable(o, { __index = self })
	return o
end

-- set water. returns the amount of water that did not fit
function set_water(self, v)
	self.water = math.min(v, self.water_max)
	return math.max(v - self.water_max, 0)
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

-- pour water from self to target bucket.
-- uses a feature of the set_water function to return the amount of water
-- that exceeded the target bucket.
function pour_to(self, target)
	self.water = target:set_water(target.water + self.water)
end
