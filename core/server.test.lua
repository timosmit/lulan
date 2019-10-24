-- TEST: LuLan server API.
-- Author: adawolfa

dofile 'core/bootstrap.test.lua'
local server = require('server')

local init
server.on('init', function(...) init = arg end)
et_InitGame(1, 2, 3)
assert(init[1] == 1 and init[2] == 2 and init[3] == 3)

local sent = {}

function et.trap_SendConsoleCommand(command, when)
	sent.command = command
	sent.when = when
end

server.exec('map supply')
assert(sent.command == 'map supply\n')
assert(sent.when == et.EXEC_APPEND)

server.exec('map supply', et.EXEC_NOW)
assert(sent.when == et.EXEC_NOW)