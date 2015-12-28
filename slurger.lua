#!/usr/bin/lua

--[==================================================================[--

                             S L U R G E R
                            ===============
                        Static/Small Lua Burger

Description
------------
This script fetches Burgerking coupons(for the european region),
downloads images and renders them in a template.


Dependencys
------------
lua5.0/lua5.1/lua5.2/lua5.3
curl or lua-socket or wget(Even the one supplied with busybox will work)


Installation
-------------
Clone the repository or untar the tarball. You're ready to go! Modify
the config table below if you don't want to use lua-socket.


Bugs
-----
Currently, using lua-socket to download the JSON does not seen to work.


Notes/todo
-----------
startup parameters


--]==================================================================]--


config = require("config")
json = require("dkjson")

if config.mkdir then
	os.execute(config.mkdir:format(config.image_dir))
end

if config.quiet then
	print = function(...) end
end


-- Downloads an URL using lua-socke, returning the HTTP's body
-- Does not work with the burgerking JSON atm... (You always get a 302
-- with the new URL pointing to the URL you specified)
function download_socket(url)
	local http = require("socket.http")
	local ltn12 = require("ltn12")
	local ans_body = {}
	http.request{
		url = url,
		sink = ltn12.sink.table(ans_body),
		redirect = true,
		headers = {
			["User-Agent"] = "Burger King App"
		}
	}
	return table.concat(ans_body)
end


-- Downloads an URL using CURL, returning curl's STDOUT(The HTTP Body)
function download_curl(url)
	local p = io.popen("curl " .. url .. " 2>/dev/null")
	local ret = p:read("*a")
	p:close()
	return ret
end


-- Downloads an URL using CURL, returning curl's STDOUT(The HTTP Body)
function download_wget(url)
	local p = io.popen("wget -O - " .. url .. " 2>/dev/null")
	local ret = p:read("*a")
	p:close()
	return ret
end


local download = _G["download_" .. config.downloader] or error("Downloader not found!")
if config.downloader == "socket" then
	print("Using lua-socket might not work ATM!")
end

-- Makes an URL shell-save by escaping non-string chars by %-notation
function url(url)
	-- Fine for now...
	return url:gsub("%A", function(c)
		if c == "/" then
			return "/"
		elseif c == ":" then
			return ":"
		elseif c == "." then
			return "."
		elseif c == " " then
			return "+"
		else
			return ("%%%x"):format(c:byte())
		end
	end)
end


local coupons
if config.json_file then
	print("Reading coupon data from disk...")
	local jsonfile = io.open(config.json_file, "r")
	coupons = json.decode(jsonfile:read("*a"))
	jsonfile:close()
else
	print("Downloading coupon list...")
	if config.http_only then
		coupons = json.decode(download("http://" .. url(config.coupon_url)))
	else
		coupons = json.decode(download("https://" .. url(config.coupon_url)))
	end
	print("Ok!")
end


           --[===[  I M A G E   D O W N L O A D I N G ]===]--


print("Downloading " .. #coupons .. " coupon images in " .. #config.image_sizes .. " sizes...")
local images = {}
for i,coupon in ipairs(coupons) do
	print("", "Downloading coupon: " .. coupon.plu .. "(" .. i .. ")")
	coupon["image_sizes"] = config.image_sizes
	for c, size in ipairs(config.image_sizes) do
		if config.mkdir then
			-- This should work on Windows and Linux
			os.execute(config.mkdir:format(config.image_dir .. config.file_sep .. size))
		end
		local download_url
		if config.http_only then
			download_url = "http://www.burgerking.de/" .. coupon["image_" .. size]
		else
			download_url = "https://www.burgerking.de/" .. coupon["image_" .. size]
		end
		local filename = coupon["image_" .. size]:match("^.+/(.*)") -- Matches everything behind the last /
		coupon["image_" .. size] = size .. "/" ..filename -- For rendering
		local filepath = config.image_dir .. config.file_sep .. size .. config.file_sep .. filename
		local outfile = io.open(filepath)
		if outfile then
			-- We can open the file for reading, so it exists.
			print("","", "skipped")
		else
			-- File does not exist yet!
			print("","",c .. "...")
			local outfile = io.open(filepath, "w")
			if outfile then
				outfile:write((download(download_url)))
				outfile:close()
			else
				error("Can't open file " .. tostring(filepath) .. " for writing. Make sure the directory exists!")
			end
		end
		
	end
end
print("Ok!")


         --[===[  T E M P L A T E   R E N D E R I N G  ]===]--        


if not config.disable_template then
	print("Rendering template...")
	-- We want to render a template.
	render = require("render")
	render(coupons)
	print("Ok!")
end


                --[===[  G O O D   B Y E ! ! !  ]===]--


os.exit(0)

-- (c) 2015 max1220
