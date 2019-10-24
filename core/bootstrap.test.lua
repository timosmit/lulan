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

et.FindSelf = function() return '' end
et.RegisterModname = function() end