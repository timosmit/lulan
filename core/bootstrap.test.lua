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

--
-- ET polyfills.
--

et = {}
et.argv = {}
et.FS_READ = 'r'

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

et.trap_Argc = function()
	return table.getn(et.argv)
end

et.trap_Argv = function(i)
	return et.argv[i + 1]
end