-- LuLan client API.
-- Author: adawolfa

local event = require('event')

local this = {}
this.clients = {}

event.extend(this)

-- Message positions.
this.CHAT  = 'chat'  -- chat area + console (without server prefix)
this.CPM   = 'cpm'   -- popup + console
this.PRINT = 'print' -- console
this.CP    = 'cp'    -- center print
this.SC    = 'sc'    -- console + stats dump

-- Banner positions (they all display in console according to client setting).
this.B_CHAT    =   8 -- chat area
this.B_POPUP   =  16 -- popup
this.B_CP      =  32 -- center print
this.B_CONSOLE =  64 -- invisible (console banner only)
this.B_TOP     = 128 -- top of screen

--- Finds clients by number or partial name match.
-- @param slot number or a string
-- @param true to allow slot number as well
-- @return client table
function this.find(term, allowNum)

	if type(term) == 'string' and string.len(term) == 0 then
		return {}
	end

	if allowNum == true and (type(term) == 'number' or string.len(term) < 3) then

		local num = tonumber(term)

		if num ~= nil and num >= 0 and num <= 63 then

			if this.clients[num] ~= nil then
				local result = {[num] = this.clients[num]}
				table.setn(result, 1)
				return result
			end

			return {}

		end

	end

	term = string.escape_pattern(string.lower(et.Q_CleanStr(term)))
	local result = {}
	local n = 0

	for i, client in pairs(this.clients) do
		if string.find(string.lower(client.name_clean), term) ~= nil then
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

--- Sends a client command to everyone.
-- @param command string
function this.command(command)
	et.trap_SendServerCommand(-1, command)
end

--- Prints a message in everyone's game.
-- @param one of CHAT, CPM, PRINT, CP constants
-- @param the message
function this.print(where, message)
	this.command(where .. ' ' .. '"' .. message .. '"')
end

--- Prints a banner in everyone's game.
-- @param a sum of B_* constants
-- @param the message
function this.banner(position, message)
	this.command('b ' .. position .. ' ' .. '"' .. message .. '"')
end

--- Called on client connect.
-- @internal this is called by the server
function this.h_connect(num, firstTime)

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

	function client.command(command)
		et.trap_SendServerCommand(client.num, command)
	end

	function client.print(where, message)
		client.command(where .. ' ' .. '"' .. message .. '"')
	end

	function client.banner(position, message)
		client.command('b ' .. position .. ' ' .. '"' .. message .. '"')
	end

	-- TODO: Consider this?
	-- event.extend(client)

	table.insert(this.clients, num, client)
	this.h_userinfo(num)

	if this.emit('connect', client, firstTime) == false then
		this.clients[num] = nil
		return false
	end

end

--- Called on client disconnect.
-- @internal this is called by the server
function this.h_disconnect(num)
	this.emit('disconnect', this.clients[num])
	table.remove(this.clients, num)
end

--- Called on client begin.
-- @internal this is called by the server
function this.h_begin(num)
	this.h_userinfo(num, true)
	this.emit('begin', this.clients[num])
end

--- Called on userinfo change.
-- @param partial - called only on begin
-- @internal this is called by the server
function this.h_userinfo(num, partial)

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
function this.h_spawn(num, revived)
	this.emit('spawn', this.clients[num], revived)
end

--- Called on client command invocation.
-- @internal this is called by the server
function this.h_command(num, command, ...)
	return this.emit('command', this.clients[num], command, unpack(arg))
end

return this