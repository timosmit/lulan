-- LuLan bootstrap.
-- Author: adawolfa

LuLan = {}
LuLan.BUNDLED = false
LuLan.VERSION = 'unknown'
LuLan.TEST    = et == nil

local modules = {}

--- Returns a module scope.
-- @param the module name
-- @return module scope
function require(module, required)

	if modules[module] == nil then

		local file = module .. '.lua'

		-- ! prefix for external dependencies.
		if string.sub(file, 1, 1) == '!' then
			file = string.sub(file, 2)
		else

			if string.sub(file, 1, 7) == 'plugin/' then
				file = 'plugins' .. string.sub(file, 7)
			else
				file = 'core/' .. file
			end

		end

		if not LuLan.TEST then
			file = et.trap_Cvar_Get("fs_homepath") .. '/etpro/lulan/' .. file
		end

		modules[module] = {}

		if required == false then

			-- This won't report an error if the file is missing or contains an error.
			pcall(function()
				modules[module].scope = dofile(file)
			end)

		else
			modules[module].scope = dofile(file)
		end

	end

	return modules[module].scope

end

--- Helper for dumping things.
-- @param... variables to be dumped
function dump(...)

	for _, var in pairs({unpack(arg)}) do

		local dump = require('!serialize.lua/serialize')(var, false)

		if LuLan.TEST then
			print(dump)
		else
			require('console').log(dump)
		end

	end

end

--- A little helper for arguments handling.
-- @param offset (default = 0)
-- @return table
local function argv(offset)

	local arguments = {}

	if offset == nil then
		offset = 0
	end

	for i = offset, et.trap_Argc() - 1 do
		table.insert(arguments, et.trap_Argv(i))
	end

	return arguments

end

--
-- ET hook functions.
--

local server  = require('server')
local console = require('console')
local client  = require('client')

require('shrubbot')

function et_InitGame(levelTime, randomSeed, restart)

	et.RegisterModname('lulan.lua ' .. et.FindSelf())

	local config = require('file').ini('lulan/lulan.ini')

	if config == nil then
		console.log('lulan: Missing lulan/lulan.ini, no plugins configured.')
	else

		for plugin in string.gfind(config.lulan.plugins, '([^ ]+)') do
			console.print('lulan: Loading plugin ' .. plugin .. '.lua')
			require('plugin/' .. plugin)
		end

	end

	server.init(levelTime, randomSeed, restart == 1)

end

function et_RunFrame(levelTime)
	server.frame(levelTime)
end

function et_ShutdownGame(restart)
	server.shutdown(restart == 1)
end

function et_Quit()
	server.quit()
end

function et_ConsoleCommand()

	if console.command(unpack(argv())) == false then
		return 1
	end

	return 0

end

function et_ClientConnect(clientNum, firstTime, isBot)
	if client.connect(clientNum, firstTime == 1) == false then
		return 'You are not allowed to join this server.'
	end
end

function et_ClientDisconnect(clientNum)
	client.disconnect(clientNum)
end

function et_ClientBegin(clientNum)
	client.begin(clientNum)
end

function et_ClientUserinfoChanged(clientNum)
	client.userinfo(clientNum)
end

function et_ClientSpawn(clientNum, revived)
	client.spawn(clientNum, revived == 1)
end

function et_ClientCommand(clientNum, command)

	if client.command(clientNum, command, unpack(argv(1))) == false then
		return 1
	end

	return 0

end