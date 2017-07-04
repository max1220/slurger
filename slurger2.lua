#!/usr/bin/env lua
local config = require("config")
local json = require("dkjson")
local template = require("template")
local ok, template_data = pcall(require, config.template)
math.randomseed(os.time())
if not ok then
	print("To run slurger you must provide the compiled template you specified in the      ")
	print("configuration file! If you want to compile your own template,")
	print("install 'https://github.com/dannote/lua-template', then")
	print("use 'templatec <input file> -o <output name>.lua' to compile them, then")
	print("copy the output to slurger2's path.")
	os.exit(1)
end
local http
if config.downloader == "socket" then
	http = require("socket.http")
end
local coupons = {}
if config.archive then
	local archive_f = io.open(config.archive, "r")
	if archive_f then
		coupons = json.decode(archive_f:read("*a"))
		archive_f:close()
	else
		print("Warning: Can't open archive file!")
	end
end


if arg[1] == "--help" then
	print("slurger2.lua")
	print(" This project came to be after discovering that the burgerking Android app")
	print(" gets you 'free' burgerking coupons(at the expense of some of your personal")
	print(" data). After some MITMing with my phone, I figured out how the app gets the")
	print(" coupon information from the burgerking server, and build a website around it,")
	print(" so you don't have to use the app anymore. As it turns out, the JSON the server")
	print(" sends to the app also contains a validity timespan for each coupon, so the app")
	print(" can cache images of upcomming coupons befor they are valid, and hide 'to old'")
	print(" coupons. The coupon codes seem to stay valid for the cashiers afterwards")
	print(" anyway, so to maximize coupon yield, this application will keep track of all")
	print(" coupons, technicly valid or not, but show appropriate warnings to the user.")
	print(" This application has been written as portable and light as possible, so that")
	print(" even a non-rooted android phone can run it, making the circle complete:")
	print(" In it's minimal configuration, it has no external dependency exept any")
	print(" version of lua and either one of lua-socket, wget or curl installed. Even the")
	print(" wget version from busybox will suffice.")
	print(" You can find this project on github: https://github.com/max1220/slurger")
	print("")
	print("config.lua")
	print(" User-configurable options are in here. This file is commented. After each")
	print(" config key, there should be a ',', to conform with Lua's table syntax.")
	print("")
	print("Templates")
	print(" slurger2 uses this templating system: https://github.com/dannote/lua-template,")
	print(" with a few bugfixes etc.")
	print(" The template will be passed a list of coupons to render. To compile a template")
	print(" of your own, use './templatec.lua <input file> -o <output name>.lua'.")
	print("")
	print("Synopsis")
	print(" ./slurger2.lua [options]")
	print(" you can provide options using the following syntax:")
	print("  --<key>=<value>")
	print(" <key> and <value> are the same as in the configuraion file, and each possible")
	print(" key is described in the default config.")
	print("")
	print("")
	print("tl;dr: It will most likely work as expected. just run ./slurger2.lua")
	os.exit(0)
elseif #arg > 0 then
	for _,v in ipairs(arg) do
		local key, value = arg:match("^--(.*)=(.-)$")
		if key and key ~= "" and value then
			if type(config[key]) == "table" then

			end


			print("Overwriting config parameter '" .. key .. "' with '" .. value "'")
			config[key] = value
		end
	end
end


function download_curl(url)
	local p = io.popen("curl '" .. url .. "' 2>/dev/null")
	local ret = p:read("*a")
	p:close()
	return ret
end

function download_wget(url)
	local p = io.popen("wget -O - '" .. url .. "' 2>/dev/null")
	local ret = p:read("*a")
	p:close()
	return ret
end

function download_socket(url)
	local body, status = http.request(config.burgerking_url)
	if status == 200 then
		return body
	else
		print("!", url, status, body)
	end
end

function download(url)
	local url = assert(url)
	if not url:sub(1, 4) == "http" then
		url = (config.disable_https and "http://" or "https://") .. url
	end
	local data
	if config.downloader == "socket" then
		data = download_socket(url)
	elseif config.downloader == "wget" then
		data = download_wget(url)
	elseif config.downloader == "curl" then
		data = download_curl(url)
	else
		print("Invalid downloader selected in config file! Defaulting to wget...")
		data = download_wget(url)
	end
	if (not data) or (data == "") then
		print("Empty data! Check internet connection and burgerking_url in config.")
		os.exit(3)
	end
	return data
end

function exists(path)
	local f = io.open(path)
	if f then
		f:close()
		return true
	end
end

function prepare_coupon(raw_coupon_data)
	for _, img_size in ipairs(config.image_sizes) do
		local img_url = raw_coupon_data["image_" .. img_size]
		local img_filename = img_size .. "_" .. img_url:match("^.+/(.*)")
		local img_path = config.image_path .. img_filename
		if exists(img_path) then
			print("Cached: " .. img_filename)
		else
			print("Downloading: " .. img_filename)
			local img = download("www.burgerking.de/" .. img_url)
			local img_f = io.open(img_path, "w")
			if not img_f then
				print("Can't open image for writing! Check image_path in config and if the target directory exists!")
				os.exit(6)
			end
			img_f:write(img)
			img_f:close()
			raw_coupon_data["local_image_" .. img_size] = config.img_rel_path .. img_filename
		end
	end
	return raw_coupon_data
end

function add_coupon(raw_coupon_data)
	local found = false
	for k,v in pairs(coupons) do
		if v.plu == raw_coupon_data.plu then
			found = true
		end
	end
	if not found then
		print("New coupon: " .. raw_coupon_data.plu)
		local coupon = prepare_coupon(raw_coupon_data)
		table.insert(coupons, coupon)
	end
end


print("Downloading coupon JSON URL: " .. config.burgerking_url.. "...")
local data = download(config.burgerking_url)
local ok, obj = pcall(json.decode, data)
if not ok then
	print("Invalid data(Can't parse as JSON)! Check internet connection and burgerking_url in config.")
	os.exit(4)
end

print("Adding new coupons...")
for _,coupon in ipairs(obj) do
	add_coupon(coupon)
end

if config.archive then
	print("Serializing archive...")
	archive_f = io.open(config.archive, "wb")
	if not archive_f then
		print("Can't open archive file for writing! Check archive in config and if the output path exists!")
		os.exit(5)
	end
	archive_f:write(json.encode(coupons))
	archive_f:close()
end

print("Rendering template...")
local template_env = {
	coupons = coupons
}

local output_f = io.open(config.output, "wb")
if not output_f then
	print("Can't open output file for writing! Check output in config and if the output path exists!")
	os.exit(5)
end
template.print(template_data, template_env, function(output)
	output_f:write(output)
end)
output_f:close()
print("All done! Good bye.")
