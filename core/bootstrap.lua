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

--
-- ET hook functions.
--

function et_InitGame(levelTime, randomSeed, restart)

	et.RegisterModname('lulan.lua ' .. et.FindSelf())

	local config = require('file').ini('lulan/lulan.ini')

	if config == nil then
		-- TODO: Print an error.
	else

		for plugin in string.gfind(config.lulan.plugins, '([^ ]+)') do
			et.G_LogPrint('[lulan] Loading plugin ' .. plugin .. '\n')
			require('plugin/' .. plugin)
		end

	end

	require('server').init(levelTime, randomSeed, restart)

end