-- Guckets Level 4
-- Made 2007 by Daniel Friesel <>
-- License: WTFPL <http://sam.zoy.org/wtfpl>

level = guckets.level:new()
level.author = "Daniel Friesel"
level.name = "Level 4"

table.insert(level.buckets, guckets.bucket:new({ water = 0, water_max = 10 }))
table.insert(level.buckets, guckets.bucket:new({ water = 0, water_max = 9 }))
table.insert(level.buckets, guckets.bucket:new({ water = 0, water_max = 8 }))
table.insert(level.buckets, guckets.bucket:new({ water = 0, water_max = 7 }))
table.insert(level.buckets, guckets.bucket:new({ water = 0, water_max = 6 }))

table.insert(level.goals, {
	callback = function (level) return level.buckets[2].water == 1 end,
	text = "%d liters of water in bucket %d",
	arguments = { 1, 2 } })
table.insert(level.goals, {
	callback = function (level) return level.buckets[3].water == 5 end,
	text = "%d liters of water in bucket %d",
	arguments = { 5, 3 } })
level:auto_spare_water()
