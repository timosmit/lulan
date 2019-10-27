-- LuLan shrubbot API.
-- Author: adawolfa

local console = require('console')
local file    = require('file')
local client  = require('client')

local this = {}

require('server').on('init', function()
	this.reload()
end)

client.on('connect', function(c)
	this.load_level(c)
end)

this.levels = {}
this.admins = {}

--- Loads shrubbot file.
function this.reload()

	local ini = file.ini('shrubbot.cfg', true, false)

	if ini ~= nil and ini.level ~= nil and ini.admin ~= nil then

		this.levels = {}
		this.admins = {}

		for _, level in ini.level do
			this.levels[tonumber(level.level)] = level
		end

		for _, admin in ini.admin do
			admin.level = tonumber(admin.level)
			this.admins[admin.guid] = admin
		end

		table.setn(this.levels, table.getn(ini.level))
		table.setn(this.admins, table.getn(ini.admin))

		console.print(string.format('lulan: Loaded %d levels and %d admins from shrubbot.cfg', table.getn(this.levels), table.getn(this.admins)))

	else
		console.log('lulan: No shrubbot.cfg file found.')
	end

	for _, c in client.clients do
		this.load_level(c)
	end

end

--- Loads a level of given client.
-- @param client instance
function this.load_level(c)
	if this.admins[c.guid] ~= nil then
		c.level = this.admins[c.guid].level
	end
end

return this