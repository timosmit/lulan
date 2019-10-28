# Writing a plugin

Plugin files are placed in `plugins` folder and they are enabled by listing them in `plugins` directive in `lulan.ini`.

## Scope

Plugin must never define a global variable, because it pollutes the global space and it could cause weird errors. Code instead of thousand words:

~~~lua
-- Bad:
variable = 5

function my_function()
end

-- Good:
local variable = 5

local function my_function()
end
~~~

You might want to stick with how core modules are implemented:

~~~lua
local this = {}

this.variable = 5

function this.function()
end

return this
~~~

This way, you can also expose your plugin as a module and other modules might access its fields and call its methods. Sure, you don't have to return anything, as described in [Core API](CoreAPI.md).

## API

Don't use standard ET Pro Lua API, unless you have a good reason for it. Most of the API is available using core modules and that API also fixes some non-uniform behaviour, such as `say` arguments handling, type casting and so forth.

Calling `et.*` functions is safe (but there's an API for most of them). Declaring `et_` prefixed functions, on the other hand, is a no-no and if you do it wrong, bad things will happen. The sane way of doing it is this:

~~~lua
local orig_et_RunFrame = et_RunFrame

function et_RunFrame(levelTime)
    -- do whatever you need to do.
    orig_et_RunFrame(levelTime)
end
~~~

## Unit test

You might (should) write a unit test for your plugin. Just create an another file `?.test.lua`:

~~~lua
-- This is essential to have the core API loaded.
dofile 'core/bootstrap.test.lua'

-- Load your plugin.
local plugin = require('plugin/my_plugin')

-- Make sure it does what it's supposed to do.
assert(plugin.my_function() == 5)
~~~

Once ready, just run it:

~~~
powershell -File lulan.ps1 -Action test
~~~

This will execute all `.test.lua` suffixed files. If no error is thrown, you didn't write your test properly (or, ultimately, you're just good to go).

It's OK to override and call ET Pro standard API functions in tests.

> **Why do I need a unit test?** Because it will reveal syntax or business logic error in less than a second contrary to spinning up a server and testing it manually (you should do that too, obviously, but you don't have to do it with every minor change). Also, if we change anything in the core or an another plugin you depend on, we will instantly know something is broken and we can fix it right away.