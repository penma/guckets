-- Guckets Level 6
-- Made 2007 by Vsevolod Kozlov <zaba@thorium.homeunix.org>
-- License: WTFPL <http://sam.zoy.org/wtfpl>

level = guckets.level:new()
level.author = "Vsevolod Kozlov"
level.name = "Level 6"

table.insert(level.buckets, guckets.bucket:new({ water = 0, water_max = 2 }))
table.insert(level.buckets, guckets.bucket:new({ water = 0, water_max = 9 }))
table.insert(level.buckets, guckets.bucket:new({ water = 0, water_max = 5 }))

table.insert(level.goals, {
	callback = function (level) return level.buckets[1].water == 1 end,
	text = "%d liters of water in bucket %d",
	arguments = { 1, 1 } })
table.insert(level.goals, {
	callback = function (level) return level.buckets[3].water == 4 end,
	text = "%d liters of water in bucket %d",
	arguments = { 4, 3 } })
level:auto_spare_water()
