module("guckets.bucket", package.seeall)

function new(self)
	o = {}
	setmetatable(o, { __index = self })
	return o
end

-- pour water from self to target bucket.
-- uses a feature of the set_water function to return the amount of water
-- that exceeded the target bucket.
function pour_to(self, target)
	sum = target.water + self.water
	target.water = math.min(sum, target.water_max)
	self.water = math.max(sum - target.water_max, 0)
end
