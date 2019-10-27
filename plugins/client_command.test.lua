-- TEST: Client command plugin.
-- Author: adawolfa

dofile 'core/bootstrap.test.lua'
require('plugin/client_command')

et.userinfo[0] = 'name\\^7adawolfa\\cl_guid\\72E1E0626BF0F2C09DEC769F3C0C44FA\\ip\\127.0.0.1:27961'
et.userinfo[1] = 'name\\^7lulan\\cl_guid\\70C6BA689D2570754D122C8A58FDAE8E\\ip\\127.0.0.1:27962'
et_ClientConnect(0, 1)
et_ClientConnect(1, 1)

local sent = {}

function et.trap_SendServerCommand(num, cmd)
	table.insert(sent, {
		num     = num,
		command = cmd,
	})
end

et.argv = {'scc', '-1', 'chat', '"foo"'}
assert(et_ConsoleCommand() == 1)

assert(table.getn(sent) == 1)
assert(sent[1].num == -1)
assert(sent[1].command == 'chat "foo"')

et.argv = {'scc', '-1', 'chat', 'foo bar'}
et_ConsoleCommand()
assert(sent[2].command == 'chat "foo bar"')

sent = {}
et.argv = {'scc', 'l', 'chat "foo"'}
et_ConsoleCommand()

assert(table.getn(sent) == 2)

-- Because clients table order is funny.
assert(sent[1].num == 0 ~= sent[2].num and (sent[1].num == 0 and sent[2].num == 1 or sent[1].num == 1 and sent[2].num == 0))

assert(sent[1].command == 'chat "foo"')
assert(sent[2].command == 'chat "foo"')

et.argv = {'scc', 'chat "foo"'}
et_ConsoleCommand()
assert(table.getn(sent) == 2)

et.argv = {'scc', '1', ''}
et_ConsoleCommand()
assert(table.getn(sent) == 2)