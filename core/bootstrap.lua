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

--- A little helper for arguments handling.
-- @return table
local function argv()

	local arguments = {}

	for i = 0, et.trap_Argc() - 1 do
		table.insert(arguments, et.trap_Argv(i))
	end

	return arguments

end

--
-- ET hook functions.
--

local server  = require('server')
local console = require('console')

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

	require('server').init(levelTime, randomSeed, restart)

end

function et_ConsoleCommand()

	if console.command(unpack(argv())) == false then
		return 1
	end

	return 0

end