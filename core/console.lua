-- LuLan console API.
-- Author: adawolfa

local this = {}

require('event').extend(this)

--- Prints a message to server console.
-- @param message
function this.print(message)
	et.G_Print(message .. '\n')
end

--- Prints a message to server console & log.
-- @param message
function this.log(message)
	et.G_LogPrint(message .. '\n')
end

--- Called on server console command.
-- @internal this is called by the server
function this.command(...)
	return this.emit('command', unpack(arg))
end

return this