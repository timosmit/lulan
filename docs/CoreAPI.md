# Core API

LuLan is composed of modules, each of them containing related functionality. Core consists of several modules and also each plugin is a module by itself.

### Accessing modules

In order to access module scope, you use `require()` function:

~~~lua
local console = require('console')
console.log('Hello world!')
~~~

You don't even have to store the module in a variable, this is more for convenience (performance reasons are negligible):

~~~lua
require('console').log('Hello world!')
~~~

There are several types of modules we distinct:

- core modules: `console`, `server`, ...,
- plugins: `plugin/fireteam_abuse` (note the prefix),
- external modules: `!serialize.lua/serialize` (note the exclamation mark indicating this is a non-LuLan module).

Calling `require()` is basically the same as calling `dofile`, except the file is only loaded on first call. On subsequent calls, an existing scope will be returned. If a module doesn't return anything **or it does not exist** (shouldn't be the case of a core module!), the result of `require()` is simply `nil`.

> **NOTE**: `bootstrap` isn't a module, don't `require()` it unless you want to break things. It's the mod entry point loading the core, plugins and forwarding hook functions calls.

### Events

Most of the core modules emit various events you can listen for. Such modules exposes `on` and `once` methods. These methods accept two arguments:

- the event identifier (string),
- a function to be called when the event happens.

If the supplied callback returns `false`, the event is intercepted and causes the event loop to stop. This means that if there are two listeners and the first one registered returns a `false`, the second one doesn't get called.

The difference between `on` and `once` is that `on` will be called every time an event is emitted, while the `once` causes the callback to be invoked exactly once (first time the event occurs).

> **NOTE**: `once` is executed before `on` listeners, so if you return `false` there, `on` handlers won't be executed at all.

~~~lua
console.on('command', function(command, param1, param2, ...)
    
    if command == 'foo' then
        -- do something and intercept the command
        return false
    end

end)
~~~

## Server

Contains server lifecycle related functionality.

### Events

`init`: Called on game startup (`et_InitGame`)
- `[number] levelTime`
- `[number] randomSeed`
- `[bool]   restart`

> **NOTE**: It doesn't make much sense to listening for this event in a plugin that doesn't care about the parameters. **In fact, plugins are loaded in `et_InitGame`**. In other words, any code outside a function is executed during game initialization. You **can** use it, but most of the time, you don't have to.

`shutdown`: Called on game shutdown (`et_ShutdownGame`)
- `[bool] restart`

`quit`: Called on mod unload (`et_Quit`)

### Methods

`exec([string] command, [number] when = et.EXEC_APPEND)`: Executes a command in server's console.
- `command`: a command to be executed **without** trailing line break
- `when`: one of `et.EXEC_APPEND`, `et.EXEC_INSERT` or `et.EXEC_NOW` constants

~~~lua
server.exec('qsay "Hello world!"')
~~~

`[table] timeout([function] callback, [number] timeout = 0)`: Executes supplied callback after specified number of milliseconds.
- `callback`: the function to be executed once the timer elapses
- `timeout`: time span in milliseconds

`[table] interval([function] callback, [number] interval = 0)`: Repeatedly executes supplied callback in an interval specified by `interval` (milliseconds).
- `callback`: the function to be executed when an interval hits the `interval`
- `interval`: interval between executions in milliseconds

> **NOTE**: This is the preferred way of scheduling things.

`cancel([table] timer)`: Cancels a pending timer returned by `timeout` or `interval`, that is, the timer won't execute and is completely removed from timers table.
- `timer`: timer to be cancelled

Example:

~~~lua
local server = require('server')

server.timeout(function()
    -- executes in the next frame.
end)

server.timeout(function()
    -- executes after 1 second
end, 1000)

local bad = server.interval(function()
    -- executes every frame (usually, this isn't a good idea!)
end)

server.interval(function()
    -- executes every second
end, 1000)

server.cancel(bad) -- won't execute again.
~~~

## Client

Clients (players) related functionality lays in this module.

### Client object

Every client is represented by an object (*table*, if you will) containing frequently used fields and several methods. In this documentation, we will refer to this object as `client.client` (because it's client instance provided by `client` module).

#### Fields

- `[number] num`: slot number
- `[table]  ent`: magic entity fields accessor (see *Entities access* below)
- `[number] team`: team number
- `[number] class`: class number
- `[string] guid`: player's GUID
- `[string] ip`: player's IP address (without port number which no one cares about)
- `[string] name`: player's name, including colors
- `[string] name_clean`: player's name without colors
- `[int]    level`: shrubbot level

#### Methods

`entity_get([number] index, [string] key)`: Returns entity field value.
- `index`: *optional* index of field's array
- `key`: field name

`entity_set([number] index, [string] key, value)`: Changes entity field value.
- `index`: *optional* index of field's array
- `key`: field name
- `value`: field value to set

> **NOTE**: Following methods are also methods of `client` module scope. They do the exact same thing, except they don't send the command to a single client, but to every one of them (broadcast, that's `-1` in standard API).

`command([string] command)`: Sends a command to the client.
- `command`: client command

`print([string] where, [string] message)`: Prints a message in the client.
- `where`: one of `client.CHAT`, `client.CPM`, `client.PRINT`, `client.CP` or `client.SC` constants
- `message`: message to be printed

`banner([int] position, [string] message)`: Prints a banner in the client.
- `position`: sum of one or more constants `client.B_CHAT`, `client.B_POPUP`, `client.B_CP`, `client.B_CONSOLE` or `client.B_TOP`
- `message`: message to be printed

#### Entities access

Client `client.client.ent` is a magic accessor of entity fields.

Instead of this:

~~~lua
dump(client.clients[0].entity_get('pers.invitationClient'))
client.clients[0].entity_set('pers.invitationClient', -1)
~~~

You can do this:

~~~lua
dump(client.clients[0].ent['pers.invitationClient'])
client.clients[0].ent['pers.invitationClient'] = -1
~~~

> **NOTE**: This is only available for non-array entity fields.

### Events

`connect`: When a client connects.
- `[client.client] client`
- `[bool]          firstTime`: is this reconnection?

`disconnect`: When a client disconnects.
- `[client.client] client`

`begin`: When a client enters the game.
- `[client.client] client`

`userinfo`: When client's userinfo changes.
- `[client.client] client`

`spawn`: When player is spawned.
- `[client.client] client`
- `[bool] revived`: was the player revived?

`command`: Called on client command (`et_ClientCommand`).
- `[client.client] client`
- `[string] command`: the command
- `[string] ...arguments`: command arguments

### Fields

- `[table<client.client>] clients`: Connected clients table, where key is client's slot number.

> **NOTE**: Due to how Lua tables work, `clients` table order is sort of undefined when iterating it. Usually, this isn't a problem, but if the order is crucial for you, use the following code:

~~~lua
for i = 0, 63 do
    if client.clients[i] ~= nil then
        -- ...
    end
end
~~~

### Methods

`[talbe<client.client>] find([string|number] term, [bool] allowNum)`: Returns list of clients matching specified term.
- `term`: name, part of name or number/numeric string if `allowNum` is `true`
- `allowNum`: if `true`, method will try to resolve the term to slot number if possible

`[client.client], [number] find_one([string|number] term)`: Returns exactly one client matching specified term. If none or multiple clients match the term, `nil` is returned. Second return value always contain number of matching clients.
- `term`: name, part of name, slot number or numeric string with slot number

## Console

Console module offers a simple way of printing, logging and listening for server's console commands.

### Events

`command`: Executed on server console command (`et_ConsoleCommand`).
- `[string] command`: the executed command
- `[string] ...arguments]`: command arguments

### Methods

`print([string] message)`: Prints a message to console.
- `message`: message without trailing line break

`log([string] message)`: Prints a message to console and server log.
- `message`: message without trailing line break

> **NOTE**: If you need to dump anything, use `dump()`. That's a globally available function which can dump any variable (including a table). It [formats it nicely](https://github.com/adawolfa/serialize.lua), it takes any number of arguments and it works everywhere - in real ET server as well as in test environment. See the code:

~~~lua
-- Dumps every client command.
client.on('command', dump)

-- A simple way of adding a caption to the variable:
dump('variable name', variable)
~~~

## Event

Provides event interface.

### Methods

`extend([table] scope)`: Adds `on`, `once` and `emit` functions to the given module scope.
- `scope`: the scope to be extended

Any module emitting events usually look like this:

~~~lua
-- plugin/my-module.lua
local this = {}

require('event').extend(this)

-- later on, you can emit an event:
if this.emit('my-event', param1, param2) == false then
    -- event was intercepted (a handler returned false)
end

return this
~~~

Consumers then can listen for `my-event`:

~~~lua
local module = require('plugin/my-module')

module.on('event', function(param1, param2)
    -- do something.
end)
~~~

## File

File module helps with reading files.

#### Methods

`[generator<string>] lines([string] filename)`: Reads a file and returns an iterator over its lines.
- `filename`: path to the file

If the file is empty, it does not exist or it contains a syntax error, `nil` is returned.

~~~lua
for _, line in file.lines('list.txt') do
    dump(line)
end
~~~

If the file does not exist, empty iterator is returned (no line is yielded).

`[table] ini([string] filename, [bool] sections = false, [bool] comments = true)`: Reads an `.ini` file and decodes it into a table.
- `filename`: path to the file
- `sections`: if there can be several sections with the same title, set it to `true` (shrubbot)
- `comments`: set to `false` to not trim out text behind `#` comment character

~~~lua
local shrubbot = file.ini('shrubbot.ini', true, false)
dump(shrubbot)
~~~

Example output:

~~~lua
{
        ["level"] = {
                {
                        ["flags"] = "ahCuiB",
                        ["level"] = "-1",
                        ["name"] = "^fDork",
                },
                {
                        ["flags"] = "ahCuiB",
                        ["level"] = "0",
                        ["name"] = "Tourist",
                },
                ...
        },
        ["admin"] = {
                {
                        ["flags"] = "",
                        ["name"] = "lulan",
                        ["guid"] = "70C6BA689D2570754D122C8A58FDAE8E",
                        ["level"] = "-1",
                },
                ...
        },
        ["ban"] = {
                {
                        ["expires"] = "0",
                        ["name"] = "banned",
                        ["guid"] = "0DD544CA4CCB44F6ED5CF12555859EB7",
                        ["banner"] = "lulan",
                        ["reason"] = "Banned by admin [expires: never]",
                        ["made"] = "11/17/18 10:36:09",
                        ["ip"] = "127.0.0.1",
                },
        },
}
~~~

> **NOTE**: Core does take care of shrubbot. Don't read it on your own, that's exactly what we want to avoid.
>
> Also, the reader does not cast values in any way.

## Shrubbot

ETAdmin compatible shrubbot core module takes care of `shrubbot.ini` reading and it does make the related work easy.

### Fields

- `[table<table>] levels`: List of shrubbot modules, where they key is level number and the value is shrubbot entry.
- `[table<table>] admins`: List of admins indexed by GUID.

~~~lua
dump(shrubbot.levels[0].name)     -- level name
dump(shrubbot.admins[guid].level) -- admin's level [number]
~~~

Shrubbot module is connected with client module. Get player's level like this:

~~~lua
dump(client.clients[0].level) -- [number]
~~~

This is available immediately after a client is connected. If there is no corresponding admin entry for the player, the level is `0` (which is how ETAdmin treats it).