-- TEST: LuLan event API.
-- Author: adawolfa

dofile 'core/bootstrap.lua'

local scope = {}
require('event').extend(scope)

assert(scope.on)
assert(scope.once)
assert(scope.emit)

local i = 0
local j = 0

scope.on('foo', function(a, b)
	assert(a == 'a')
	assert(b == 'b')
	i = i + 1
end)

scope.once('foo', function()
	j = j + 1
end)

scope.emit('foo', 'a', 'b')
scope.emit('foo', 'a', 'b')

assert(i == 2)
assert(j == 1)

scope.once('foo', function()
	return false
end)

scope.emit('foo')

assert(i == 2)