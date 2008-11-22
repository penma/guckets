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

table.insert(level.goals, guckets.goal.water({bucket = 2, water = 1}))
table.insert(level.goals, guckets.goal.water({bucket = 3, water = 5}))
level:auto_spare_water()
