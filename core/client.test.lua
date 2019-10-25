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

et_ClientConnect(0, 1)

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