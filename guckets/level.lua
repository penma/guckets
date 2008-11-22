-- Guckets
-- Made 2006, 2007, 2008 by Lars Stoltenow <penma@penma.de>
-- License: WTFPL <http://sam.zoy.org/wtfpl>

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

-- convenience functions to manage pouring. these include filling and emptying
-- (which are really just the same as pouring from/to the spare bucket).
function bucket_fill(self, n)
	self.spare_bucket:pour_to(self.buckets[n])
end

function bucket_empty(self, n)
	self.buckets[n]:pour_to(self.spare_bucket)
end

function bucket_pour(self, from, to)
	self.buckets[from]:pour_to(self.buckets[to])
end

-- goal checking
-- each goal is a subroutine that returns either true or false, depending on
-- whether the condition is fulfilled
-- obviously, when all conditions are met, the level is won.
function goal_check(self)
	local k, v
	local won
	for k, v in next, self.goals do
		if not v["callback"](self) then return false end
	end
	return true
end

-- load a level from a file
-- protects the global namespace from accidental changes of the level file.
-- it does *not* prevent it from using _G.foo to escape, but that's not the
-- point. the purpose is simply to prevent accidental changes.
function load(name)
	if type(name) ~= "string" then error("load is not a method of guckets.level, but a function in a package") end
	local env = {}
	setmetatable(env, { __index = _G })
	setfenv(1, env)
	setfenv(0, env)
	
	status, msg = pcall(dofile, name)
	if not status then print(string.format("Could not open level file: %s", msg)) os.exit(1) end
	
	return level
end
