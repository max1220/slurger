return {
	burgerking_url = "www.burgerking.de/de/de/getCoupons/$2y$10$lMF/mOz7BqqVlAdzL0hvVuTF2WJqxACdATIVCteknYh2genKPuuHu",
	-- you should not need to change this unless burgerking changes it's 'API'.

	downloader = "wget",
	-- backend used for downloading the JSON & images.
	-- Possible options: socket, wget, curl

	template = "default_template",
	-- the compiled template. See README.MD (or run slurger2.lua --help)

	output = "index.html",
	-- The rendered version of the template will be stored here.

	archive = "archive.json",
	-- path to archive JSON. nil for not keeping an archive.

	image_path = "img/",
	-- Where to store images. Leading slash is important.

	img_rel_path = "img/",
	-- Image path relative to template output. Leading slash is important.

	image_sizes = { 286, 429, 572, 858 },
	-- image sizes to download.
	-- Possible options: 286, 429, 572, 858
}
