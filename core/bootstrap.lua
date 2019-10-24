-- LuLan bootstrap.
-- Author: adawolfa

LuLan = {}
LuLan.BUNDLED = false
LuLan.VERSION = 'unknown'

local modules = {}

--- Returns a module scope.
-- @param the module name
-- @return module scope
function require(module, required)

	if modules[module] == nil then

		local file = module .. '.lua'

		-- ! prefix for external dependencies.
		if string.sub(file, 1, 2) == '!' then
			file = string.sub(file, 2)
		else

			if string.sub(file, 1, 8) == 'plugin/' then
				file = 'plugins' .. string.sub(file, 8)
			else
				file = 'core/' .. file
			end

			if LuLan.BUNDLED then
				file = 'lulan/' .. file
			end

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
	require('server').init(levelTime, randomSeed, restart)
end