# Unified ETPro lua module

This is an extensible Lua module for ETPro servers. It unifies various small modules, introduces shared interface for reading shrubbot files and accessing player data, simplifies persistent data storage and introduces event system.

## Contributing

No module (core or plugin) should declare global variable or function, always use `local` or encapsulate your plugin in a self-calling function. Keep already used formatting and use the right (that's tab!) indent character.

Running tests:

~~~
powershell -File lulan.ps1 -Action test
~~~

The PS script will automatically download and extract Lua 5.0.3 into `lua` directory, so you don't have to install anything.

You can run a single test suite as well:

~~~
powershell -File lulan.ps1 -Action test core/bootstrap.test.lua
~~~

When testing on your local server, you can create a junction from this cloned repository into your ETPro folder like this:

~~
mklink /J "C:\Program Files (x86)\Enemy Territory\etpro\lulan" C:\Users\<user>\..\lulan"
~~

And then run it:

~~
etded.exe +set fs_game etpro +set lua_modules "lulan/core/bootstrap.lua" +map goldrush
~~

In case you need to dump a variable, do this:

~~~
local serialize = require('!serialize.lua/serialize')
et.G_LogPrint(serialize(var) .. '\n') -- or print() in a test.
~~~