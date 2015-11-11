#!/usr/bin/lua

--[==================================================================[--

                             S L U R G E R
                              C O N F I G
                            ===============
                        Config file for slurger

--]==================================================================]--

return {

	-- Coupon data URL. This one is for germany. Other regions might
	-- have diffrent URL's. You should not prefix this with http or https
	coupon_url = "www.burgerking.de/de/de/getCoupons/$2y$10$lMF/mOz7BqqVlAdzL0hvVuTF2WJqxACdATIVCteknYh2genKPuuHu",

	-- Downloader. Possible values are: socket(using lua-socket, prefered), curl, wget
	downloader = "curl",
	
	-- Disable HTTPS download. (Required on some minimal busybox builds)
	http_only = false,
	
	-- Seperator for file names. Under everything but windows this is /
	file_sep = "/",
	
	-- If you set this to a string, required directorys are created automaticly.
	-- Set to false to disable this behaviour. You should set this to "mkdir %s" for windows.
	mkdir = "mkdir -p %s",
	
	-- Don't download JSON, use this file instead(filename or false)
	-- Intended for debugging use only!
	json_file = false,

	-- Where to download images to
	image_dir = "img",
	
	-- What size(s) of images to download? Possible values are:
	-- 286, 429, 572, 858
	image_sizes = { 286, 429, 572, 858 },

	-- Disable template output(only download images)
	disable_templates = false,
	
	-- Disable all output
	quiet = false,

	-- Settings dedicated to template rendering. These only apply to the
	-- stock template renderer.
	template = {

		-- Template to render into
		template = "template_bootstrap.html",
		
		-- Template for each item
		template_item = "template_item.html",

		-- Path before any image
		image_wwwdir = "img/",

		-- Date format. Refer to: http://www.lua.org/pil/22.1.html
		date_format = "%c",
		
		-- File to save the rendered site to
		outfile = "index.html"

	}
}
