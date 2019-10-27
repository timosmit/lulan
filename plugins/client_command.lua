-- Sends an entered client command from server console.
-- Author: adawolfa

local console = require('console')
local client  = require('client')

console.on('command', function(command, target, ...)

	if command == 'scc' then

		local client_command = ''

		for i, a in ipairs(arg) do
			if i > 1 and string.find(a, ' ') ~= nil then
				client_command = client_command .. ' "' .. a .. '"'
			else
				client_command = client_command .. ' ' .. a
			end
		end

		client_command = string.sub(client_command, 2)

		if client_command == nil or client_command == '' then
			console.log('usage: scc <target> "<command>"')
			return false
		end

		if target == '-1' then
			client.command(client_command)
			return false
		end

		local clients = client.find(target, true)

		if table.getn(clients) == 0 then
			console.log('scc: no target found')
			return false
		end

		for _, c in clients do
			c.command(client_command)
		end

		return false

	end

end)
