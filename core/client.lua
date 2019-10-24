-- LuLan client API.
-- Author: adawolfa

local event = require('event')

local this = {}
this.clients = {}

event.extend(this)

--- Finds a client by number or partial name match.
-- @param slot number or a string
-- @return client or nil
function this.find(term)
end

--- Called on client connect.
-- @internal this is called by the server
function this.connect(num, firstTime)

	local client = {
		num = num,
	}

	-- TODO: Consider this?
	-- event.extend(client)

	this.clients[num] = client

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
end

--- Called on userinfo change.
-- @internal this is called by the server
function this.userinfo(num)
end

--- Called on client spawn.
-- @internal this is called by the server
function this.spawn(num, revived)
	this.emit('spawn', this.clients[num], revived)
end

return this