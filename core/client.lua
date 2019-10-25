-- LuLan client API.
-- Author: adawolfa

local event = require('event')

local this = {}
this.clients = {}

event.extend(this)

--- Finds clients by number or partial name match.
-- @param slot number or a string
-- @return client table
function this.find(term)

	term = et.Q_CleanStr(term)
	local result = {}
	local n = 0

	for i, client in pairs(this.clients) do
		if string.find(client.name_clean, term) ~= nil then
			result[i] = client
			n = n + 1
		end
	end

	table.setn(result, n)

	return result

end

--- Finds exactly one client by number or partial name match.
-- @param slot number or a string
-- @param
function this.find_one(term)

	if type(term) == 'number' or string.len(term) < 3 then

		term = tonumber(term)

		if term == nil or term < 0 or term > 63 or this.clients[term] == nil then
			return nil, 0
		end

		return this.clients[term], 1

	end

	local clients = this.find(term)

	if table.getn(clients) ~= 1 then
		return nil, table.getn(clients)
	end

	for _, client in pairs(clients) do
		return client, 1
	end

end

--- Called on client connect.
-- @internal this is called by the server
function this.connect(num, firstTime)

	local client = {
		num = num,
		ent = {},
	}

	setmetatable(client.ent, {
		__index = function(_, k)
			return client.entity_get(k)
		end,
		__newindex = function(_, k, v)
			return client.entity_set(k, v)
		end,
	})

	function client.entity_get(key, index)
		return et.gentity_get(client.num, key, index)
	end

	function client.entity_set(key, index, value)
		et.gentity_set(client.num, key, index, value)
	end

	-- TODO: Consider this?
	-- event.extend(client)

	this.clients[num] = client
	this.userinfo(num)

	if this.emit('connect', client, firstTime) == false then
		this.clients[num] = nil
		return 'You are not allowed to join this server.'
	end

end

--- Called on client disconnect.
-- @internal this is called by the server
function this.disconnect(num)
	this.emit('disconnect', this.clients[num])
	this.clients[num] = nil
end

--- Called on client begin.
-- @internal this is called by the server
function this.begin(num)
	this.userinfo(num, true)
	this.emit('begin', this.clients[num])
end

--- Called on userinfo change.
-- @param partial - called only on begin
-- @internal this is called by the server
function this.userinfo(num, partial)

	local client = this.clients[num]

	client.class = client.ent['sess.playerType']
    client.team  = client.ent['sess.sessionTeam']

	if partial ~= true then
		local userinfo = et.trap_GetUserinfo(num)
		client.guid = et.Info_ValueForKey(userinfo, 'cl_guid')
		client.ip   = string.gsub(et.Info_ValueForKey(userinfo, 'ip'), ':[0-9]+$', '')
		client.name = et.Info_ValueForKey(userinfo, 'name')
		client.name_clean = et.Q_CleanStr(client.name)
		this.emit('userinfo', this.clients[num])
	end

end

--- Called on client spawn.
-- @internal this is called by the server
function this.spawn(num, revived)
	this.emit('spawn', this.clients[num], revived)
end

return this