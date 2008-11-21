#!/usr/bin/env lua
require "guckets"

pass = 0
fail = 0

-- run a test for everything up to m1 (maximum water bucket 1) and m2
-- verify using table t, row index: source + 1, col index: target + 1
-- list entries: expected state b1/b2
function test_pour_table(m1, m2, t)
	b1 = guckets.bucket:new()
	b2 = guckets.bucket:new()
	b1.water_max = m1
	b2.water_max = m2
	
	for ba1 = 0, m1 do
		for ba2 = 0, m2 do
			b1.water = ba1
			b2.water = ba2
			
			b1:pour_to(b2)
			
			if b1.water == t[ba1+1][ba2+1][1] and b2.water == t[ba1+1][ba2+1][2] then
				io.write("O")
				pass = pass + 1
			else
				io.write(".")
				fail = fail + 1
			end
		end
	end
end

-- run a test for everything up to m1 (maximum water bucket 1) and m2
-- verify by doing a simple check whether nothing overflowed, and whether no
-- water was leaked (too much or too little water)
function test_pour_plausible(m1, m2)
	b1 = guckets.bucket:new()
	b2 = guckets.bucket:new()
	b1.water_max = m1
	b2.water_max = m2
	
	for ba1 = 0, m1 do
		for ba2 = 0, m2 do
			b1.water = ba1
			b2.water = ba2
			
			b1:pour_to(b2)
			
			if   b1.water + b2.water == ba1 + ba2
			 and b1.water <= m1 and b2.water <= m2
			 then
				io.write("O")
				pass = pass + 1
			else
				io.write(".")
				fail = fail + 1
			end
		end
	end
end

test_pour_table(6, 5, {
	--  to 0      to 1      to 2      to 3      to 4      to 5
	{ { 0, 0 }, { 0, 1 }, { 0, 2 }, { 0, 3 }, { 0, 4 }, { 0, 5 } }, -- from 0
	{ { 0, 1 }, { 0, 2 }, { 0, 3 }, { 0, 4 }, { 0, 5 }, { 1, 5 } }, -- from 1
	{ { 0, 2 }, { 0, 3 }, { 0, 4 }, { 0, 5 }, { 1, 5 }, { 2, 5 } }, -- from 2
	{ { 0, 3 }, { 0, 4 }, { 0, 5 }, { 1, 5 }, { 2, 5 }, { 3, 5 } }, -- from 3
	{ { 0, 4 }, { 0, 5 }, { 1, 5 }, { 2, 5 }, { 3, 5 }, { 4, 5 } }, -- from 4
	{ { 0, 5 }, { 1, 5 }, { 2, 5 }, { 3, 5 }, { 4, 5 }, { 5, 5 } }, -- from 5
	{ { 1, 5 }, { 2, 5 }, { 3, 5 }, { 4, 5 }, { 5, 5 }, { 6, 5 } }  -- from 6
})

test_pour_table(5, 3, {
	--  to 0      to 1      to 2      to 3
	{ { 0, 0 }, { 0, 1 }, { 0, 2 }, { 0, 3 } }, -- from 0
	{ { 0, 1 }, { 0, 2 }, { 0, 3 }, { 1, 3 } }, -- from 1
	{ { 0, 2 }, { 0, 3 }, { 1, 3 }, { 2, 3 } }, -- from 2
	{ { 0, 3 }, { 1, 3 }, { 2, 3 }, { 3, 3 } }, -- from 3
	{ { 1, 3 }, { 2, 3 }, { 3, 3 }, { 4, 3 } }, -- from 4
	{ { 2, 3 }, { 3, 3 }, { 4, 3 }, { 5, 3 } }  -- from 5
})

test_pour_plausible(15, 5)

io.write("\n")

io.write("Pass: " .. pass .. " Fail: " .. fail .. " Total: " .. (pass + fail) .. "\n")
os.exit(fail)
