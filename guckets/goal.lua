-- Guckets
-- Made 2006, 2007, 2008 by Lars Stoltenow <penma@penma.de>
-- License: WTFPL <http://sam.zoy.org/wtfpl>

module("guckets.goal", package.seeall)

function water(params)
	return {
		callback = function (level)
			return level.buckets[params["bucket"]].water == params["water"]
		end,
		text = "%d liters of water in bucket %d",
		arguments = { params["water"], params["bucket"] }
	}
end
