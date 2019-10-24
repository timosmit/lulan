-- LuLan file API.
-- Author: adawolfa

local this = {}

--- Returns an line iterator over a file.
-- @param filename
-- @return iterator
function this.lines(filename)

	local fd, len = et.trap_FS_FOpenFile(filename, et.FS_READ)

	if len == -1 then
		return function() end
	end

	local buffer = ''

	return function()

		while buffer ~= nil do

			local s, e = string.find(buffer, '[\r\n]+')

			if s ~= nil then

				local part = string.sub(buffer, 1, s - 1)
				buffer = string.sub(buffer, e + 1)

				if part ~= '' then
					return part
				end

			else

				if finish then

					local part = buffer
					buffer = nil

					if part ~= '' then
						return part
					else
						break
					end

				end

				local read = 1024

				if read > len then
					read = len
				end

				len = len - read

				if read == 0 then

					et.trap_FS_FCloseFile(fd)

					local remain = buffer
					buffer = nil

					if remain ~= '' then
						return remain
					end

					break

				end

				buffer = buffer .. et.trap_FS_Read(fd, read) -- TODO: Can it return less?

			end

		end

	end

end

--- Parses an INI file.
-- @param filename
-- @param true if there are several sections with the same name (e.g. shrubbot)
-- @param false for INI files where comments aren't used (e.g. shrubbot)
-- @return table or nil if there's an error
function this.ini(filename, sections, comments)

	local ini
	local section

	for line in this.lines(filename) do

		if ini == nil then
			ini = {} -- empty file = error?
		end

		if comments ~= false then
			line = string.gsub(line, '[;#].+$', '')
		end

		line = string.gsub(line, '^%s+', '')
		line = string.gsub(line, '%s+$', '')

		if line ~= '' then

			local key, value = string.gfind(line, "(.-)%s*=%s*(.-)$")()

			if key ~= nil then

				if section == nil then
					ini[key] = value
				else
					section[key] = value
				end

			else

				local s = string.gfind(line, "%[(.+)%]")()

				if s ~= nil then

					if sections then

						section = {}

						if ini[s] == nil then
							ini[s] = {}
						end

						table.insert(ini[s], section)

					else

						if ini[s] == nil then
							ini[s] = {}
						end

						section = ini[s]

					end

				else
					return nil
				end

			end

		end

	end

    return ini

end

return this