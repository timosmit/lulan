-- TEST: LuLan file API.
-- Author: adawolfa

dofile 'core/bootstrap.test.lua'
local file = require('file')

local lines = {}
for line in file.lines('lines.txt') do
	table.insert(lines, line)
end
assert(lines[1] == 'foo' and lines[2] == 'bar' and lines[3] == 'cyp' and lines[4] == nil)

local ini = file.ini('shrubbot.cfg', true, false)

assert(ini)
assert(ini.level)
assert(ini.level[1].level == '-1')
assert(ini.admin)
assert(ini.admin[2].name == 'adawolfa')
assert(ini.ban)
assert(ini.ban[1].banner == 'lulan')