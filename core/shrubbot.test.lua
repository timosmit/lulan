-- TEST: LuLan shrubbot API.
-- Author: adawolfa

dofile 'core/bootstrap.test.lua'
local shrubbot = require('shrubbot')
local client   = require('client')

shrubbot.reload()

assert(table.getn(shrubbot.levels) == 3)
assert(table.getn(shrubbot.admins) == 2)

et.userinfo[1] = 'name\\^7adawolfa\\cl_guid\\72E1E0626BF0F2C09DEC769F3C0C44FA\\ip\\127.0.0.1:27962'
et_ClientConnect(1, 1)

assert(client.clients[1].level == 1)