-- TEST: LuLan server API.
-- Author: adawolfa

dofile 'core/bootstrap.test.lua'
local server = require('server')

local init
server.on('init', function(...) init = arg end)
et_InitGame(1, 2, 1)
assert(init[1] == 1 and init[2] == 2 and init[3] == true)

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

local status

server.on('shutdown', function(restart)
	status = restart
end)

et_ShutdownGame(1)
assert(status == true)

et_ShutdownGame(0)
assert(status == false)

server.on('quit', function()
	status = 'quit'
end)

et_Quit()

assert(status == 'quit')

local times = 0

server.timeout(function()
	times = times + 1
end)

et_RunFrame(0)
et_RunFrame(50)

assert(times == 1)

local timer = server.interval(function()
	times = times + 1
end)

et_RunFrame(100)
et_RunFrame(150)

server.cancel(timer)
et_RunFrame(200)

assert(times == 3)

server.timeout(function() times = times + 1 end)
server.timeout(function() times = times + 1 end)
server.timeout(function() times = times + 1 end)

et_RunFrame(250)

assert(times == 6)

et_RunFrame(300)

server.timeout(function() undefined() end) -- keep this number at line 92

local message

function et.G_LogPrint(m)
	message = m
end

et_RunFrame(350)

assert(table.getn(server.timers) == 0)
assert(message == 'lulan: Error occurred in timer: lulan/core\\server.test.lua:79: attempt to call global `undefined\' (a nil value)\n')

server.cvars.sv_hostname = '^1ETHost'
assert(server.cvars.sv_hostname == '^1ETHost')