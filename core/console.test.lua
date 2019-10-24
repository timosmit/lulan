-- TEST: LuLan console API.
-- Author: adawolfa

dofile 'core/bootstrap.test.lua'

-- argv() indirect test, also console hook test.
local console = require('console')
local arguments = {}

console.on('command', function(command, a, b)

	arguments.command = command
	arguments.a = a
	arguments.b = b

	if command == 'cancel' then
		return false
	end

end)

et.argv = {'command', 1, 2}
assert(et_ConsoleCommand() == 0)
assert(arguments.command == 'command')
assert(arguments.a == 1)
assert(arguments.b == 2)

et.argv = {'cancel'}
assert(et_ConsoleCommand() == 1)
assert(arguments.command == 'cancel')

-- console.print & console.log
local message

function et.G_LogPrint(s)
	message = 'L:' .. s
end

function et.G_Print(s)
	message = s
end

console.print('hello world')
assert(message == 'hello world\n')

console.log('hello world')
assert(message == 'L:hello world\n')