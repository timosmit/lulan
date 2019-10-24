-- TEST: LuLan server API.
-- Author: adawolfa

dofile 'core/bootstrap.test.lua'
local server = require('server')

local init
server.on('init', function(...) init = arg end)
et_InitGame(1, 2, 3)
assert(init[1] == 1 and init[2] == 2 and init[3] == 3)