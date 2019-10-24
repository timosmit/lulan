-- TEST: LuLan shrubbot API.
-- Author: adawolfa

dofile 'core/bootstrap.test.lua'
local shrubbot = require('shrubbot')

shrubbot.reload()

assert(table.getn(shrubbot.levels) == 3)
assert(table.getn(shrubbot.admins) == 2)