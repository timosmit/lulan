-- LuLan shrubbot API.
-- Author: adawolfa

local console = require('console')
local file    = require('file')

local this = {}

require('server').on('init', function()
	this.reload()
end)

this.levels = {}
this.admins = {}

--- Loads shrubbot file.
function this.reload()

	local ini = file.ini('shrubbot.cfg', true, false)

	if ini ~= nil and ini.level ~= nil and ini.admin ~= nil then
		this.levels = ini.level
		this.admins = ini.admin
		console.print(string.format('lulan: Loaded %d levels and %d admins from shrubbot.cfg', table.getn(this.levels), table.getn(this.admins)))
	else
		console.log('lulan: No shrubbot.cfg file found.')
	end

end

return this