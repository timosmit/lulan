-- LuLan server API.
-- Author: adawolfa

local this = {}

require('event').extend(this)

--- Called on game initialization.
-- @internal this is called by the server
function this.init(levelTime, randomSeed, restart)
	this.emit('init', levelTime, randomSeed, restart)
end

--- Executes a server console command.
-- @param the command to be executed (without trailing line break)
-- @param one of et.EXEC_APPEND (default), et.EXEC_INSERT or et.EXEC_NOW
function this.exec(command, when)

	if when == nil then
		when = et.EXEC_APPEND
	end

	et.trap_SendConsoleCommand(command .. '\n', when)

end

return this