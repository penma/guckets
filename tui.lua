#!/usr/bin/env lua
require "guckets"

dofile(arg[1])

function help(topic)
	if not topic then print [[
Guckets Text User Interface
Made 2006, 2007, 2008 Lars Stoltenow <penma@penma.de>

Commands:
    help [<optarg>]  - Show help message
    fill <n>         - Fill bucket n
    empty <n>        - Empty bucket n
    pour <n1> <n2>   - Pour water from bucket n1 to bucket n2

Optional argument for help:
    description      - Game description
    spare            - What is the spare bucket
]] end
	if topic == "description" then print [[
A short description of Guckets

Guckets is a game where you must fill buckets with water. Starting with just
two buckets, you will get more buckets to manage. The goal is to have a
specific amount of water in one (or probably more) bucket. Sounds easy, but
you are not allowed to measure the water you fill into your buckets. Thus,
you can only fill your buckets with water, or you can empty them, or you can
pour all water into another bucket (until it's full). Depending on the level,
you maybe don't have unlimited water, so you must think to reach the goal.
]] end
	if topic == "spare" then print [[
What is the spare bucket?

The spare bucket is the internal representation of the amount of water you
can bring into game, in addition to the water that's in the buckets after
loading a level. In most levels, it will not be limited, but there might be
some which place a limit on this for an additional challenge.
]] end
end

function print_state(level)
	local k, v
	print("- Current level --------------------------------------------------------------")
	print("Buckets:")
	for k, v in next, level.buckets do
		local vis
		vis = "|"
		for i =           1, v.water     do vis = vis .. "****|" end
		for i = v.water + 1, v.water_max do vis = vis .. "....|" end
		
		print(string.format("  Bucket %d: %d / %d %s", k, v.water, v.water_max, vis))
	end
	print(string.format("  Spare bucket: %d / %d", level.spare_bucket.water, level.spare_bucket.water_max))
	print("Goals to reach:")
	for k, v in next, level.goals do
		if v.callback(level) then
			print("* " .. string.format(v["text"], unpack(v["arguments"])))
		else
			print("  " .. string.format(v["text"], unpack(v["arguments"])))
		end
	end
	print()
end

help()

print_state(level)
io.write("> ")

for input in io.lines() do
	-- parse the line by words
	words = {}
	for word in string.gmatch(input, "%S+") do table.insert(words, word) end
	
	if words[1] == "fill"  then level:bucket_fill(tonumber(words[2])) end
	if words[1] == "empty" then level:bucket_empty(tonumber(words[2])) end
	if words[1] == "pour"  then level:bucket_pour(tonumber(words[2]), tonumber(words[3])) end
	
	if words[1] == "help" then help(words[2]) end
	
	print_state(level)
	if level:goal_check() then
		print("Congratulations, you've solved this level!")
		os.exit(0)
	end
	
	io.write("> ")
end
