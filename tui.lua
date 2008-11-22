#!/usr/bin/env lua
-- Guckets
-- Made 2006, 2007, 2008 by Lars Stoltenow <penma@penma.de>
-- License: WTFPL <http://sam.zoy.org/wtfpl>

require "guckets"

if arg[1] == nil then print [[
Guckets Text User Interface
Made 2006, 2007, 2008 Lars Stoltenow <penma@penma.de>

Usage: guckets-tui <level.lua>
]] os.exit(2) end

-- open the level
level = guckets.level.load(arg[1])

-- ----------------------------- ONLINE HELP ---------------------------------
function help(topic)
	if not topic then print [[
Guckets Text User Interface
Made 2006, 2007, 2008 Lars Stoltenow <penma@penma.de>

Commands:
    help [<optarg>]  - Show help message
    show             - Show the bucket state
    fill <n>         - Fill bucket n
    empty <n>        - Empty bucket n
    pour <n1> <n2>   - Pour water from bucket n1 to bucket n2
    exit, quit       - Exit

Optional argument for help:
    description      - Game description
    spare            - What is the spare bucket]] end
	if topic == "description" then print [[
A short description of Guckets

Guckets is a game where you must fill buckets with water. Starting with just
two buckets, you will get more buckets to manage. The goal is to have a
specific amount of water in one (or probably more) bucket. Sounds easy, but
you are not allowed to measure the water you fill into your buckets. Thus,
you can only fill your buckets with water, or you can empty them, or you can
pour all water into another bucket (until it's full). Depending on the level,
you maybe don't have unlimited water, so you must think to reach the goal.]] end
	if topic == "spare" then print [[
What is the spare bucket?

The spare bucket is the internal representation of the amount of water you
can bring into game, in addition to the water that's in the buckets after
loading a level. In most levels, it will not be limited, but there might be
some which place a limit on this for an additional challenge.]] end
end

-- ---------------------------- STATE DUMPER ---------------------------------
function print_state(level)
	local k, v
	print("Current level")
	print()
	print("Buckets:")
	for k, v in next, level.buckets do
		local vis
		vis = "|"
		for i =           1, v.water     do vis = vis .. "****|" end
		for i = v.water + 1, v.water_max do vis = vis .. "....|" end
		
		print(string.format("     %2d: %2d / %2d %s", k, v.water, v.water_max, vis))
	end
	print(string.format("     Spare bucket: %2d / %2d", level.spare_bucket.water, level.spare_bucket.water_max))
	print("Goals to reach:")
	for k, v in next, level.goals do
		if v.callback(level) then
			print("[OK] " .. string.format(v["text"], unpack(v["arguments"])))
		else
			print("     " .. string.format(v["text"], unpack(v["arguments"])))
		end
	end
end

-- ------------------------------- MAIN LOOP ---------------------------------
help()
print()
print_state(level)
io.write("> ")

changed = 0

for input in io.lines() do
	-- parse the line by words
	words = {}
	for word in string.gmatch(input, "%S+") do table.insert(words, word) end
	
	-- bucket operations
	if words[1] == "fill" or words[1] == "empty" then
		local n
		n = tonumber(words[2])
		if n ~= nil and n > 0 and n <= # level.buckets then
			if words[1] == "fill" then
				print(string.format("Filling bucket %d", n))
				level:bucket_fill(n)
			else
				print(string.format("Emptying bucket %d", n))
				level:bucket_empty(n)
			end
			changed = 1
		else
			print("ERROR: No such bucket.")
		end
	elseif words[1] == "pour" then
		local n1, n2
		n1 = tonumber(words[2])
		n2 = tonumber(words[3])
		if n1 ~= nil and n2 ~= nil and n1 > 0 and n1 <= # level.buckets and n2 > 0 and n2 <= # level.buckets then
			if n1 ~= n2 then
				print(string.format("Pouring water from bucket %d to bucket %d", n1, n2))
				level:bucket_pour(n1, n2)
				changed = 1
			else
				print("Source and destination bucket are the same!")
			end
		else
			print("ERROR: No such bucket.")
		end
	
	-- help and all else
	elseif words[1] == "help" then help(words[2])
	elseif words[1] == "show" then changed = 1
	elseif words[1] == "exit" or words[1] == "quit" then os.exit(0)
	elseif words[1] == nil then -- nothing
	else
		print("No such command.")
	end
	
	if changed == 1 then print_state(level) changed = 0 end
	if level:goal_check() then
		print("Congratulations, you've solved this level!")
		os.exit(0)
	end
	
	io.write("> ")
end
