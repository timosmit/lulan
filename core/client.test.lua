-- TEST: LuLan client API.
-- Author: adawolfa

dofile 'core/bootstrap.test.lua'
local client = require('client')

et.userinfo[0] = 'name\\^7lulan\\cl_guid\\70C6BA689D2570754D122C8A58FDAE8E\\ip\\127.0.0.1:27961'
local c

client.on('connect', function(p)
	c = p
end)

et.entities[0] = {
	['sess.deaths'] = 12,
	['ps.powerups'] = {5},
	['sess.playerType'] = 2,
	['sess.sessionTeam'] = 1,
}

client.once('connect', function() return false end)
assert(et_ClientConnect(0, 1) == 'You are not allowed to join this server.')

assert(et_ClientConnect(0, 1) == nil)

assert(c)
assert(client.clients[0] == c)
assert(c.num == 0)
assert(c.name == '^7lulan')
assert(c.name_clean == 'lulan')
assert(c.guid == '70C6BA689D2570754D122C8A58FDAE8E')
assert(c.ip == '127.0.0.1')
assert(c.class == 2)
assert(c.team == 1)

local e

client.on('begin', function(p)
	assert(p == c)
	e = 'begin'
end)

et_ClientBegin(0)
assert(e == 'begin')

local spawn = {}

client.on('spawn', function(p, revived)
	spawn.client  = p
	spawn.revived = revived
end)

et_ClientSpawn(0, 1)
assert(spawn.client == c)
assert(spawn.revived == true)

et_ClientSpawn(0, 0)
assert(spawn.revived == false)

assert(c.ent['sess.deaths'] == 12)
assert(c.entity_get('ps.powerups', 0) == 5)

c.ent['sess.deaths'] = 13
c.entity_set('ps.powerups', 0, 6)

assert(c.ent['sess.deaths'] == 13)
assert(c.entity_get('ps.powerups', 0) == 6)

local command = {}

function et.trap_SendServerCommand(num, cmd)
	command.num = num
	command.command = cmd
end

c.command('cpm "foo"')

assert(command.num == 0)
assert(command.command == 'cpm "foo"')

client.command('cpm "bar"')

assert(command.num == -1)
assert(command.command == 'cpm "bar"')

local disconnect = nil

client.on('disconnect', function(p)
	disconnect = p.num
end)

et_ClientDisconnect(0)
assert(disconnect == 0)
assert(client.clients[0] == nil)

client.clients = {
	[0] = {
		num = 0,
		name_clean = 'lulan',
	},
	[1] = {
		num = 1,
		name_clean = 'lucy',
	},
}

local find, count

find = client.find('lan')
assert(find[0].num == 0)
assert(table.getn(find) == 1)

find = client.find('lu')
assert(find[0].num == 0)
assert(find[1].num == 1)
assert(table.getn(find) == 2)

find = client.find('cat')
assert(table.getn(find) == 0)

find, count = client.find_one(0)
assert(find.num == 0)
assert(count == 1)

find, count = client.find_one(-1)
assert(find == nil)
assert(count == 0)

find, count = client.find_one('1')
assert(find.num == 1)
assert(count == 1)

find, count = client.find_one('l^3ul')
assert(find.num == 0)
assert(count == 1)

find, count = client.find_one('^5lu')
assert(find == nil)
assert(count == 2)

command = {}

client.on('command', function(client, cmd, a, b)

	command.client = client
	command.command = cmd
	command.a = a
	command.b = b

	if cmd == 'cancel' then
		return false
	end

end)

et.argv = {'command', 'a', 'b'}
assert(et_ClientCommand(1, 'command') == 0)

assert(command.client == client.clients[1])
assert(command.command == 'command')
assert(command.a == 'a')
assert(command.b == 'b')

assert(et_ClientCommand(1, 'cancel') == 1)