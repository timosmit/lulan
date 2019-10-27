-- TEST: Fireteam invites anti-abuse plugin.
-- Author: adawolfa

dofile 'core/bootstrap.test.lua'
local client = require('client')
local plugin = require('plugin/fireteam_abuse')

et.userinfo[0] = 'name\\^7lulan\\cl_guid\\70C6BA689D2570754D122C8A58FDAE8E\\ip\\127.0.0.1:27961'
et.userinfo[1] = 'name\\^7adawolfa\\cl_guid\\72E1E0626BF0F2C09DEC769F3C0C44FA\\ip\\127.0.0.1:27962'

et.entities[0] = {['pers.invitationClient'] = -1, ['pers.applicationClient'] = 1}
et.entities[1] = {['pers.invitationClient'] = 0, ['pers.applicationClient'] = -1}

et_ClientConnect(0, 1)
et_ClientConnect(1, 1)

local cmd = {}

function et.trap_SendServerCommand(num, command)
	cmd.num = num
	cmd.command = command
end

et.argv = {'fireteam', 'inviteall'}
et_ClientCommand(0, 'fireteam')
et_RunFrame(50)

assert(plugin.interactions[0][1] == 1)

et_ClientCommand(0, 'fireteam')
et_RunFrame(100)

assert(cmd.num == nil)

et_ClientCommand(0, 'fireteam')
et_RunFrame(150)

assert(cmd.num == 1)
assert(cmd.command == 'invitation -5')
assert(et.entities[1]['pers.invitationClient'] == -1)

cmd = {}

et.argv = {'fireteam', 'apply'}
et_ClientCommand(1, 'fireteam')
et_RunFrame(200)

et_ClientCommand(1, 'fireteam')
et_RunFrame(200)

assert(cmd.num == nil)

et_ClientCommand(1, 'fireteam')
et_RunFrame(200)

assert(cmd.num == 0)
assert(cmd.command == 'application -5')
assert(et.entities[0]['pers.applicationClient'] == -1)

et_ClientDisconnect(0)
assert(plugin.interactions[0] == nil)
assert(plugin.interactions[1][0] == nil)