-- TEST: LuLan event API.
-- Author: adawolfa

local this = {}

--- Adds on(), once() and emit() functions to supplied scope.
-- @param scope
function this.extend(scope)

	local on = {}
	local once = {}

	--- Listens for an event.
	-- @param event name
	-- @param callback
	function scope.on(event, callback)
	
		if on[event] == nil then
			on[event] = {}
		end
		
		table.insert(on[event], callback)
	
	end
	
	--- Listens for a first occurrence of an event.
	-- @param event name
	-- @param callback
	function scope.once(event, callback)
	
		if once[event] == nil then
			once[event] = {}
		end
		
		table.insert(once[event], callback)
	
	end
	
	
	--- Emits an event.
	-- @param event name
	-- @param... arguments
	function scope.emit(event, ...)

		if once[event] ~= nil then
			
			local onces = once[event]
			once[event] = nil
			
			for _, callback in ipairs(onces) do
				if callback(unpack(arg)) == false then
					return false
				end
			end
			
		end
		
		if on[event] ~= nil then

			for _, callback in ipairs(on[event]) do
				if callback(unpack(arg)) == false then
					return false
				end
			end
			
		end
	
	end

end

return this