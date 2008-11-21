level = guckets.level:new()
level.author = "penma"
level.name = "Level 1"

table.insert(level.buckets, guckets.bucket:new({ water = 0, water_max = 5 }))
table.insert(level.buckets, guckets.bucket:new({ water = 0, water_max = 3 }))

table.insert(level.goals, {
	callback = function (level) return level.buckets[1].water == 4 end,
	text = "%d liters of water in bucket %d",
	arguments = { 4, 1 } })
level:auto_spare_water()
