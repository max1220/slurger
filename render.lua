#!/usr/bin/lua

--[==================================================================[--

                             S L U R G E R
                            T E M P L A T E
                           R E N D E R I N G
                          ===================

Description
------------
This file is responsible for rendering templates of slurger.
The returned function is called once with the coupons as parameter,
so you can easily modify how templates are renderd. The function
should return true if rendering succeded, false otherwise. You need
to write to files yourself, so you could easily split your HTML to
multiple files.
Settings from config are aviable as the global config table.


Values
-------
The table passed to the returned function contains serveral important
fields. Here's a list of the ones you need:

	plu
		PLU of the coupon. This is the actaul coupon. The cashier needs
		to type it in the cash register.
		
	description & title
		The description of the current item. Unfortionally, it's not
		machine-readable and contains the item description and price.
		description & title seem to always be the same value.

	image_{286,429,572,858}
		The image file name.
		
	image_sizes
		Table containing the image sizes.
		
	from
		Start of coupon validity as unix time
		
	to
		Stop of coupon validity as unix time

--]==================================================================]--



return function(coupons)
	local template_file = io.open(config.template.template)
	local template = template_file:read("*a")
	template_file:close()

	local template_item_file = io.open(config.template.template_item)
	local template_item = template_item_file:read("*a")
	template_item_file:close()
	
	-- Indent as much as {{coupons in indented}}
	-- local indent = template:find("{{coupons}}") or 0
	local indent = #template:match("\n(%s*){{coupons}}")
	template_item = template_item:gsub("[^\r\n]+", function(str)
		return string.rep("\t", indent) .. str
	end)

	local rendered = "\t\t<div class=\"coupon-container\">\n"

	for _,coupon in ipairs(coupons) do
		if tonumber(coupon.to) or 0 > os.time() then
			local data = {
				description = (coupon.description or coupon.title or ""),
				to = os.date(config.template.date_format, tonumber(coupon.to)),
				from = os.date(config.template.date_format, tonumber(coupon.from)),
				plu = coupon.plu
			}
			for _,size in pairs(config.image_sizes) do
				data["image_" .. size] = config.template.image_wwwdir .. coupon["image_" .. size]
			end
			rendered = rendered .. template_item:gsub("{{(.-)}}", function(value)
				-- Replace everything in double brackets with the value in data or ""
				return (data[value] or ""):gsub("%%", "&x25;")
			end)
		end
	end

	rendered = rendered .. "\n\t\t</div>"

	local outfile = io.open(config.template.outfile, "w")
	outfile:write(template:gsub("{{coupons}}", rendered))
	outfile:close()
	
	return true

end
