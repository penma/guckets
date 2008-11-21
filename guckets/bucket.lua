-- Guckets
-- Made 2006, 2007, 2008 by Lars Stoltenow <penma@penma.de>
-- License: WTFPL <http://sam.zoy.org/wtfpl>

module("guckets.bucket", package.seeall)

function new(self, o)
	local o = o or {
		water = 0,
		water_max = 0
	}
	setmetatable(o, { __index = self })
	return o
end

-- pour water from self to target bucket.
-- uses a feature of the set_water function to return the amount of water
-- that exceeded the target bucket.
function pour_to(self, target)
	local sum = target.water + self.water
	target.water = math.min(sum, target.water_max)
	self.water = math.max(sum - target.water_max, 0)
end
