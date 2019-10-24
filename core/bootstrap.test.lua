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
et.FS_READ = 'r'

et.FindSelf = function() return '' end
et.RegisterModname = function() end

et.trap_FS_FOpenFile = function(filename, mode)

	local fd, _ = io.open('fixtures/' .. filename, mode)

	if fd == nil then
		return -1
	end

	local scope = {
		buffer = '',
		seek   = 1
	}

	for line in fd:lines() do
		scope.buffer = scope.buffer .. line .. '\n'
	end

	return scope

end

et.trap_FS_Read = function(fd, len)
	local s = string.sub(fd.buffer, fd.seek, fd.seek + len)
	fd.seek = fd.seek + len
	return s
end

et.trap_FS_FCloseFile = function(fd)
end