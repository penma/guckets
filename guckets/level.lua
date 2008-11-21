module("guckets.level", package.seeall)

function new(self)
	local o = {
		name = "", author = "",
		
		buckets = { },
		spare_bucket = guckets.bucket:new(),
		goals = { }
	}
	setmetatable(o, { __index = self })
	return o
end

-- Automatically create the spare bucket to contain enough water to fill
-- the remaining buckets with water and to empty all buckets.
-- Useful for the common type of levels that do not have any actual constraints
-- on how much additional water can go in the buckets
function auto_spare_water(self)
	local k, v
	local water_avail, water_max
	water_avail = 0
	water_max = 0
	for k, v in next, self.buckets do
		water_avail = water_avail + v.water
		water_max   = water_max   + v.water_max
	end
	self.spare_bucket.water     = water_max - water_avail
	self.spare_bucket.water_max = water_max
end
