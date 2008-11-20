#!/usr/bin/env lua
require "guckets"

b1 = guckets.bucket:new()
b2 = guckets.bucket:new()
b1.water_max = 6
b2.water_max = 5

-- Table storing the expected results.
-- rows: source, cols: target, list entries: values b1/b2 after forward/reverse pour
expected = {
	--  to 0            to 1            to 2            to 3            to 4            to 5
	{ { 0, 0, 0, 0 }, { 0, 1, 1, 0 }, { 0, 2, 2, 0 }, { 0, 3, 3, 0 }, { 0, 4, 4, 0 }, { 0, 5, 5, 0 } }, -- from 0
	{ { 0, 1, 1, 0 }, { 0, 2, 2, 0 }, { 0, 3, 3, 0 }, { 0, 4, 4, 0 }, { 0, 5, 5, 0 }, { 1, 5, 6, 0 } }, -- from 1
	{ { 0, 2, 2, 0 }, { 0, 3, 3, 0 }, { 0, 4, 4, 0 }, { 0, 5, 5, 0 }, { 1, 5, 6, 0 }, { 2, 5, 6, 1 } }, -- from 2
	{ { 0, 3, 3, 0 }, { 0, 4, 4, 0 }, { 0, 5, 5, 0 }, { 1, 5, 6, 0 }, { 2, 5, 6, 1 }, { 3, 5, 6, 2 } }, -- from 3
	{ { 0, 4, 4, 0 }, { 0, 5, 5, 0 }, { 1, 5, 6, 0 }, { 2, 5, 6, 1 }, { 3, 5, 6, 2 }, { 4, 5, 6, 3 } }, -- from 4
	{ { 0, 5, 5, 0 }, { 1, 5, 6, 0 }, { 2, 5, 6, 1 }, { 3, 5, 6, 2 }, { 4, 5, 6, 3 }, { 5, 5, 6, 4 } }, -- from 5
	{ { 1, 5, 6, 0 }, { 2, 5, 6, 1 }, { 3, 5, 6, 2 }, { 4, 5, 6, 3 }, { 5, 5, 6, 4 }, { 6, 5, 6, 5 } }  -- from 6
}

pass = 0
fail = 0
total = 0

for ba1 = 0, 6 do
	for ba2 = 0, 5 do
		b1.water = ba1
		b2.water = ba2
		
		b1:pour_to(b2)
		
		if b1.water == expected[ba1+1][ba2+1][1] and b2.water == expected[ba1+1][ba2+1][2] then
			io.write("O")
			pass = pass + 1
		else
			io.write(".")
			fail = fail + 1
		end
		
		b2:pour_to(b1)
		
		if b1.water== expected[ba1+1][ba2+1][3] and b2.water == expected[ba1+1][ba2+1][4] then
			io.write("O")
			pass = pass + 1
		else
			io.write(".")
			fail = fail + 1
		end
		
		total = total + 2
	end
end
io.write("\n")

io.write("Pass: " .. pass .. " Fail: " .. fail .. " Total: " .. total .. "\n")
os.exit(fail)
