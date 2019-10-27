-- LuLan chat API.
-- Author: adawolfa

local client = require('client')

local this = {}

require('event').extend(this)

-- This ensures the chat hook is the last one invoked.
require('server').timeout(function()
	client.on('command', function(c, command, recipient, message)

		if command == 'say' or command == 'say_team' or command == 'say_buddy' or command == 'say_teamnl' then
			return this.h_message(c, command, recipient, nil)
		elseif command == 'pm' or command == 'pmt' then
			return this.h_message(c, command, message, recipient)
		end

	end)
end)

--- Called on a chat or private message.
function this.h_message(who, command, message, recipient)

	if message == '' then
		return
	end

	local recipients = nil

	if recipient ~= nil then
		recipients = client.find(recipient, true)
	end

	if this.emit(command, who, message, recipients) == false then
		return false
	end

	if this.emit('message', command, who, message, recipients) == false then
		return false
	end

end

return this