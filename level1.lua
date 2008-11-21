-- Guckets Level 1
-- Made 2007 by Lars Stoltenow <penma@penma.de>
-- License: WTFPL <http://sam.zoy.org/wtfpl>

level = guckets.level:new()
level.author = "Lars Stoltenow"
level.name = "Level 1"

table.insert(level.buckets, guckets.bucket:new({ water = 0, water_max = 2 }))
table.insert(level.buckets, guckets.bucket:new({ water = 0, water_max = 3 }))

table.insert(level.goals, {
	callback = function (level) return level.buckets[2].water == 1 end,
	text = "%d liters of water in bucket %d",
	arguments = { 1, 2 } })
level:auto_spare_water()
