-- Fireteam invites anti-abuse plugin.
-- Author: adawolfa

local this = {}
local client  = require('client')
local server  = require('server')

local config = arg[1] or {}
this.limit = tonumber(config.limit or 2)

local PERS_INVITATION  = 'pers.invitationClient'
local PERS_APPLICATION = 'pers.applicationClient'
local CMD_INVITATION   = 'invitation'
local CMD_APPLICATION  = 'application'

this.interactions = {}

client.on('command', function(who, command, action, argument)

	if command == 'fireteam' then
		if action == 'invite' or action == 'invitenum' or action == 'inviteall' then
			server.timeout(function()
				this.invites(who)
			end)
		elseif action == 'apply' then
			server.timeout(function()
				this.applies(who)
			end)
		end
	end

end)

client.on('disconnect', function(who)

	if this.interactions[who.num] ~= nil then
		this.interactions[who.num] = nil
	end

	for _, interaction in this.interactions do
		if interaction[who.num] ~= nil then
			interaction[who.num] = nil
		end
	end

end)

--- Called when someone is inviting to a fireteam.
function this.invites(who)
	for _, whom in client.clients do
		if whom.ent[PERS_INVITATION] == who.num then
			this.interact(who, whom, CMD_INVITATION, PERS_INVITATION)
		end
	end
end

--- Called when someone is applying to a fireteam.
function this.applies(who)
	for _, whom in client.clients do
		if whom.ent[PERS_APPLICATION] == who.num then
			this.interact(who, whom, CMD_APPLICATION, PERS_APPLICATION)
		end
	end
end

--- Called on fireteam interaction.
function this.interact(who, whom, command, pers)

	this.advance(who, whom)

	if this.is_excessive(who, whom) then
		whom.command(command .. ' -5')
		whom.ent[pers] = -1
	end

end

--- Advances fireteam interaction counter.
function this.advance(who, whom)

	if this.interactions[who.num] == nil then
		this.interactions[who.num] = {}
	end

	this.interactions[who.num][whom.num] = (this.interactions[who.num][whom.num] or 0) + 1

end

--- Determines whether the invitation is beyond the limit.
function this.is_excessive(who, whom)
	return this.interactions[who.num][whom.num] > this.limit
end

return this