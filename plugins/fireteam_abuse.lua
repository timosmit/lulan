-- Fireteam invites anti-abuse plugin.
-- Author: adawolfa

local this = {}
local client = require('client')

client.on('command', function(p, command, action, argument)

	if command == 'vote' and (action == 'yes' or action == 'no') then
		this.response(p, action == 'yes')
		return
	end

	if command ~= 'fireteam' then
		return
	end

	if argument ~= nil then

		if action == 'invite' then

			-- no eligible matching names found
			-- fireteam invite found %d players matching %s

			local whoms = client.find(argument)

			for _, whom in pairs(whoms) do
				this.invite(p, whom)
			end

		else if action == 'invitenum'

			-- Invalid client selected

			local whom, count = client.find_one(argument)

			if whom ~= nil then
				this.invite(p, whom)
			end

		end

		return

	end

	if action == 'inviteall'

		for _, whom in pairs(client.clients) do
			this.invite(p, whom)
		end

	end

end)

--- Called when a player invites someone to his fireteam.
-- @param who is inviting?
-- @param who is being invited?
function this.invite(who, whom)

	if who.team ~= whom.team then
		return
	end

	-- we need to check if whom has ps.fireteam set?
	-- we need to check pers.invitationClient loop

end

--- Called when a player "votes".
-- @param who is being invited
-- @param response true/false
function this.respond(whom, response)
end

return this