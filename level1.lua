-- Guckets Level 1
-- Made 2007 by Lars Stoltenow <penma@penma.de>
-- License: WTFPL <http://sam.zoy.org/wtfpl>

level = guckets.level:new()
level.author = "Lars Stoltenow"
level.name = "Level 1"

table.insert(level.buckets, guckets.bucket:new({ water = 0, water_max = 2 }))
table.insert(level.buckets, guckets.bucket:new({ water = 0, water_max = 3 }))

table.insert(level.goals, guckets.goal.water({bucket = 2, water = 1}))
level:auto_spare_water()
