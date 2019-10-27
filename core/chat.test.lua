-- TEST: LuLan chat API.
-- Author: adawolfa

dofile 'core/bootstrap.test.lua'
local chat   = require('chat')
local client = require('client')

local msg = {
	message  = {},
	specific = {}
}

chat.on('message', function(command, who, message, recipients)
	msg.message = {
		command    = command,
		who        = who,
		message    = message,
		recipients = recipients
	}
end)

for _, e in {'say', 'say_team', 'say_buddy', 'say_teamnl', 'pm', 'pmt'} do
	local cmd = e
	chat.on(e, function(who, message, recipients)

		msg.specific = {
			command    = cmd,
			who        = who,
			message    = message,
			recipients = recipients
		}

		if message == 'bar' then
			return false
		end

	end)
end

et.userinfo[0] = 'name\\^7adawolfa\\cl_guid\\72E1E0626BF0F2C09DEC769F3C0C44FA\\ip\\127.0.0.1:27961'
et.userinfo[1] = 'name\\^7lulan\\cl_guid\\70C6BA689D2570754D122C8A58FDAE8E\\ip\\127.0.0.1:27962'
et_ClientConnect(0, 1)
et_ClientConnect(1, 1)

et.argv = {'say', 'foo'}
et_ClientCommand(0, 'say')

-- Shouldn't be hooked, yet.
assert(msg.message.command == nil)
et_RunFrame(0)

et_ClientCommand(0, 'say')

assert(msg.message.command == 'say')
assert(msg.message.who.num == 0)
assert(msg.message.message == 'foo')
assert(msg.message.recipients == nil)

assert(msg.specific.command == 'say')
assert(msg.specific.who.num == 0)
assert(msg.specific.message == 'foo')
assert(msg.specific.recipients == nil)

et_ClientCommand(0, 'say_team')
assert(msg.message.command == 'say_team')
assert(msg.specific.command == 'say_team')

et_ClientCommand(0, 'say_buddy')
assert(msg.message.command == 'say_buddy')
assert(msg.specific.command == 'say_buddy')

assert(et_ClientCommand(0, 'say_teamnl') == 0)
assert(msg.message.command == 'say_teamnl')
assert(msg.specific.command == 'say_teamnl')

et.argv = {'say', 'bar'}
assert(et_ClientCommand(0, 'say') == 1)
assert(msg.specific.command == 'say')
assert(msg.message.command == 'say_teamnl') -- shouldn't change.

et.argv = {'pm', 'l', 'private'}
et_ClientCommand(0, 'pm')

assert(msg.message.command == 'pm')
assert(msg.message.message == 'private')
assert(msg.message.recipients[0].num == 0)
assert(msg.message.recipients[1].num == 1)

assert(msg.specific.command == 'pm')
assert(msg.specific.message == 'private')
assert(msg.specific.recipients[0].num == 0)
assert(msg.specific.recipients[1].num == 1)

et.argv = {'pm', 'foo', 'private'}
et_ClientCommand(0, 'pm')

assert(table.getn(msg.message.recipients) == 0)

et.argv = {'pm', '1', 'private'}
et_ClientCommand(0, 'pm')

assert(table.getn(msg.message.recipients) == 1)
assert(msg.message.recipients[1].num == 1)