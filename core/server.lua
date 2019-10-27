-- LuLan server API.
-- Author: adawolfa

local this = {}
this.timers = {}
this.level_time = 0

require('event').extend(this)

--- Called on game initialization.
-- @internal this is called by the server
function this.h_init(levelTime, randomSeed, restart)
	this.emit('init', levelTime, randomSeed, restart)
end

--- Called on each frame.
-- @internal this is called by the server
function this.h_frame(levelTime)

	this.level_time = levelTime

	local n = table.getn(this.timers)

	if n == 0 then
		return
	end

	-- We're gonna iterate twice - first loop will run timers, second one will remove the buried ones.
	-- This a) keeps us safe from table.remove on iterated table b) is also a little bit more efficient.

	for i = 1, n do

		local timer = this.timers[i]

		if timer.timeout <= this.level_time then

			local result, error = pcall(timer.callback)

			if timer.interval ~= nil then
				timer.timeout = this.level_time + timer.interval
			else
				this.timers[i] = nil
			end

			if result == false then
				require('console').log('lulan: Error occurred in timer: lulan/' .. error)
			end

		end

	end

	for i = 1, n do

		if this.timers[n - i + 1] == nil then
			table.remove(this.timers, n - i + 1)
		end

	end

end

--- Called on game shutdown.
-- @internal this is called by the server
function this.h_shutdown(restart)
	this.emit('shutdown', restart)
end

--- Called on mod unload.
-- @internal this is called by the server
function this.h_quit()
	this.emit('quit')
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

--- Schedules a timer.
-- @param callback
-- @param timeout in milliseconds (nil = next frame)
-- @param timer
function this.timeout(callback, timeout)

	if timeout == nil or timeout < 0 then
		timeout = 0
	end

	local timer = {
		callback = callback,
		timeout  = this.level_time + timeout,
	}

	table.insert(this.timers, timer)
	return timer

end

--- Schedules an interval.
-- @param callback
-- @param interval in milliseconds (nil = every frame)
-- @param timer
function this.interval(callback, interval)

	if interval == nil or interval < 0 then
		interval = 0
	end

	local timer = {
		callback = callback,
		timeout  = this.level_time + interval,
		interval = interval,
	}

	table.insert(this.timers, timer)
	return timer

end

--- Cancels a timer.
-- @param timer
function this.cancel(timer)

	for i, item in pairs(this.timers) do
		if item == timer then
			table.remove(this.timers, i)
			break
		end
	end

end

return this