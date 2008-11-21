-- Guckets
-- Made 2006, 2007, 2008 by Lars Stoltenow <penma@penma.de>
-- License: WTFPL <http://sam.zoy.org/wtfpl>

module("test", package.seeall)

local pass, fail
pass = 0
fail = 0

function section(text)
	io.write("* " .. text .. "\n")
end

function condition(text, cond)
	if cond then
		io.write(string.format("%-60s %s\n", text, "PASS"))
		pass = pass + 1
	else
		io.write(string.format("%-60s %s\n", text, "FAIL"))
		fail = fail + 1
	end
end

function results()
	io.write("\nTests completed, here are the results\n")
	io.write(string.format("Total number of tests: %d   Successful tests: %d   Failed tests: %d\n",
		pass + fail, pass, fail))
	os.exit(fail)
end
