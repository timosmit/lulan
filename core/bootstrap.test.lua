-- TEST: LuLan bootstrap.
-- Include this file into other test suites as well.
-- Author: adawolfa

dofile 'core/bootstrap.lua'

assert(LuLan)

-- require() core module.
local server = require('server')
assert(server)

-- require() missing module.
local foo

pcall(function() foo = require('foo') end)
assert(foo == nil)

-- require() optional module.
local bar = require('bar', false)
assert(bar == nil)

-- string.escape_pattern()
assert(string.escape_pattern('^[a*c%]$') == '%^%[a%*c%%%]%$')

--
-- ET polyfills.
--

et = {}
et.cvars = {}
et.configstrings = {}
et.argv = {}
et.userinfo = {}
et.entities = {}
et.FS_READ = 'r'
et.EXEC_NOW    = 0
et.EXEC_INSERT = 1
et.EXEC_APPEND = 2

et.FindSelf = function() return '' end
et.RegisterModname = function() end

et.trap_FS_FOpenFile = function(filename, mode)

	local fd, _ = io.open('fixtures/' .. filename, mode)

	if fd == nil then
		return nil, -1
	end

	local scope = {
		buffer = '',
		seek   = 1
	}

	for line in fd:lines() do
		scope.buffer = scope.buffer .. line .. '\n'
	end

	return scope, string.len(scope.buffer)

end

et.trap_FS_Read = function(fd, len)
	local s = string.sub(fd.buffer, fd.seek, fd.seek + len)
	fd.seek = fd.seek + len
	return s
end

et.trap_FS_FCloseFile = function(fd)
end

et.G_LogPrint = function()
end

et.G_Print = function()
end

et.trap_Argc = function()
	return table.getn(et.argv)
end

et.trap_Argv = function(i)
	return et.argv[i + 1]
end

et.trap_GetUserinfo = function(num)
	return et.userinfo[num]
end

et.Info_ValueForKey = function(s, k)
	return string.gfind(s, k .. '\\([^\\]+)')()
end

et.Q_CleanStr = function(s)
	return string.gsub(s, '%^.', '')
end

et.gentity_get = function(num, name, index)

	if et.entities[num] == nil then
		return nil
	end

	if index == nil then
		return et.entities[num][name]
	else
		return et.entities[num][name][index + 1]
	end

end

et.gentity_set = function(num, name, index, value)
	if value == nil then
		et.entities[num][name] = index
	else
		et.entities[num][name][index + 1] = value
	end
end

et.trap_Cvar_Get = function(cvar)
	return et.cvars[cvar]
end

et.trap_Cvar_Set = function(cvar, value)
	et.cvars[cvar] = value
end

et.trap_GetConfigstring = function(index)
	return et.configstrings[index]
end

et.trap_SetConfigstring = function(index, value)
	et.configstrings[index] = value
end