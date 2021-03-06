-- LuLan bootstrap.
-- Author: adawolfa

LuLan = {}
LuLan.VERSION = '0.0.0'
LuLan.TEST    = et == nil
LuLan.config  = nil

local modules = {}

--- Returns a module scope.
-- @param the module name
-- @return module scope
function require(module, required)

	if modules[module] == nil then

		local file = module .. '.lua'
		local arguments = {}

		-- ! prefix for external dependencies.
		if string.sub(file, 1, 1) == '!' then
			file = string.sub(file, 2)
		else

			if string.sub(file, 1, 7) == 'plugin/' then
				local plugin = string.sub(file, 8)
				file = 'plugins/' .. plugin
				if LuLan.config ~= nil and LuLan.config[plugin] ~= nil then
					arguments = {LuLan.config[plugin]}
				end
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
				local factory = loadfile(file)
				modules[module].scope = factory(arguments)
			end)

		else

			local factory, err = loadfile(file)

			if factory ~= nil then
				modules[module].scope = factory(arguments)
			elseif error ~= nil then
				error(err)
			end

		end

	end

	return modules[module].scope

end

--
-- Various helpers.
--

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

--- Escapes pattern for string.gsub() or string.find().
-- @param the pattern to be escaped
-- @return escaped pattern
function string.escape_pattern(pattern)
	pattern = string.gsub(pattern, '%%', '%%%%')
	pattern = string.gsub(pattern, '([-+=<>?*%[%]()_])', '%%%1')
	pattern = string.gsub(pattern, '^%^', '%%^')
	pattern = string.gsub(pattern, '%$$', '%%$')
	return pattern
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
require('chat')

function et_InitGame(levelTime, randomSeed, restart)

	et.RegisterModname('lulan.lua ' .. et.FindSelf())

	LuLan.config = require('file').ini('lulan/lulan.ini')

	if LuLan.config == nil then
		console.log('lulan: Missing lulan/lulan.ini, no plugins configured.')
	else

		for plugin in string.gfind(LuLan.config.lulan.plugins, '([^ ]+)') do
			console.print('lulan: Loading plugin ' .. plugin .. '.lua')
			require('plugin/' .. plugin)
		end

	end

	server.h_init(levelTime, randomSeed, restart == 1)

end

function et_RunFrame(levelTime)
	server.h_frame(levelTime)
end

function et_ShutdownGame(restart)
	server.h_shutdown(restart == 1)
end

function et_Quit()
	server.h_quit()
end

function et_ConsoleCommand()

	local command = string.lower(et.trap_Argv(0))

	if console.h_command(command, unpack(argv(1))) == false then
		return 1
	end

	return 0

end

function et_ClientConnect(clientNum, firstTime, isBot)
	if client.h_connect(clientNum, firstTime == 1) == false then
		return 'You are not allowed to join this server.'
	end
end

function et_ClientDisconnect(clientNum)
	client.h_disconnect(clientNum)
end

function et_ClientBegin(clientNum)
	client.h_begin(clientNum)
end

function et_ClientUserinfoChanged(clientNum)
	client.h_userinfo(clientNum)
end

function et_ClientSpawn(clientNum, revived)
	client.h_spawn(clientNum, revived == 1)
end

function et_ClientCommand(clientNum, command)

	local arguments = argv(1)

	-- Message in console breaks into individual arguments.
	if command == 'say' and table.getn(arguments) > 1 then

		local concat = ''

		for _, a in arguments do
			concat = concat .. ' ' .. a;
		end

		arguments = {string.sub(concat, 2)}

	end

	if client.h_command(clientNum, string.lower(command), unpack(arguments)) == false then
		return 1
	end

	return 0

end