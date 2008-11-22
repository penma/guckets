-- Guckets Level 2
-- Made 2007 by Lars Stoltenow <penma@penma.de>
-- License: WTFPL <http://sam.zoy.org/wtfpl>

level = guckets.level:new()
level.author = "Lars Stoltenow"
level.name = "Level 2"

table.insert(level.buckets, guckets.bucket:new({ water = 0, water_max = 5 }))
table.insert(level.buckets, guckets.bucket:new({ water = 0, water_max = 3 }))

table.insert(level.goals, guckets.goal.water({bucket = 1, water = 4}))
level:auto_spare_water()
