local template = {}

function template.escape(data)
	return tostring(data or ""):gsub("[\">/<'&]", {
		["&"] = "&amp;",
		["<"] = "&lt;",
		[">"] = "&gt;",
		['"'] = "&quot;",
		["'"] = "&#39;",
		["/"] = "&#47;"
	})
end

function template.print(data, args, callback, env)
	local env = env or _G
	local callback = callback or print
	local function exec(data)
		if type(data) == "function" then
			local args = args or {}
			setmetatable(args, { __index = env })
			setfenv(data, args)
			data(exec)
		else
			callback(tostring(data or ''))
		end
	end
	exec(data)
end

function template.parse(data, minify)
	local str =
[========[return function(_write)
	function write(...)
		local args = {}
		for k,v in pairs({...}) do
			args[k] = tostring(v)
		end
		_write(unpack(args))
	end
	function write_esc(...)
		write(tostring(...):gsub("[\">/<'&]", {
		["&"] = "&amp;",
		["<"] = "&lt;",
		[">"] = "&gt;",
		['"'] = "&quot;",
		["'"] = "&#39;",
		["/"] = "&#47;"
	}))
	end
	write[====[]========] ..
		data
			:gsub("[][]====[][]", ']====]write"%1"write[====[')
			:gsub("<%%=", "]====]write(")
			:gsub("<%%", "]====]write_esc(")
			:gsub("%%>", ")write[====[")
			:gsub("<%?", "]====] ")
			:gsub("%?>", "write[====[")
	.. "]====] end"

	if minify then
		str = str
			:gsub("^[ %s]*", "")
			:gsub("[ %s]*$", "")
			:gsub("%s+", " ")
	end
	return str
end

function template.compile(...)
	return loadstring(template.parse(...))()
end

return template
