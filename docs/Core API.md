# Core API

LuLan is composed from modules, each of them containing related functionality. Core consists of several modules and also each plugin is a module by itself.

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

Calling `require()` is basically the same as calling `dofile`, except the file is only loaded on first call. On subsequent calls, an existing scope will be returned. If a module doesn't return anything, the result of `require()` is simply `nil`.

> **NOTE**: `bootstrap` isn't a module, don't `require()` it unless you want to break things. It's the mod entry point loading the core, plugins and forwarding hook functions calls.

### Events

Most of the core modules emit various events you can listen for. Such modules exposes `on` and `once` methods. These methods accept two arguments:

- the event identifier (string),
- a function to be called when the event happens.

If the supplied callback returns `false`, the event is intercepted and causes the event loop to stop. This means that if there are two listeners and the first one registered returns a `false`, the second one doesn't get called.

The difference between `on` and `once` is that `on` will be called every time an event is emitted, while the `once` causes the callback to be invoked exactly once (first the the event occurs).

~~~lua
console.on('command', function(command, param1, param2, ...)
    
    if command == 'foo' then
        -- do something and intercept the command
        return false
    end

end)
~~~

## Server

### Events

`init`: Called on game startup (`et_InitGame`)
- `[number] levelTime`
- `[number] randomSeed`
- `[bool]   restart`

`shutdown`: Called on game shutdown (`et_ShutdownGame`)
- `[bool] restart`

`quit`: Called on mod unload (`et_Quit`)

### Methods

`exec([string] command, [number] when = et.EXEC_APPEND)`: Executes a command in server's console.
- `command`: a command to be executed **without** trailing line break
- `when`: one of `et.EXEC_APPEND`, `et.EXEC_INSERT` or `et.EXEC_NOW` constants

`[table] timeout([function] callback, [number] timeout = 0)`: Executes supplied callback after specified number of milliseconds.
- `callback`: the function to be executed once the timer elapses
- `timeout`: time span in milliseconds

`[table] interval([function] callback, [number] interval = 0)`: Repeatedly executes supplied callback in an interval specified by `interval` (milliseconds).
- `callback`: the function to be executed when an interval hits the `interval`
- `interval`: interval between executions in milliseconds

> **NOTE**: This is the preferred way of scheduling things.

`cancel([table] timer)`: Cancels a pending timer returned by `timeout` or `interval`, that is, the timer won't execute and is completely removed from timers table.
- `timer`: timer to be cancelled