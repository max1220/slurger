return function(_write)
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
	write[====[]====] 
local current = {}
local archived = {}
local extra = {}
local motds = {
	"Now with 3% more burgers!",
	"There is a realistic chance of a random burger encounter on this site!",
	"May contain burger!",
	"Most cerntainly contains burger!",
	"A vegetarian's nightmare!",
	"Also try other fastfood!",
	"4 times a day to keep the doctor away!",
	"Doctor's hate it!",
	"8/8 gr8, m8(no h8)!",
	"made by me!",
	"come have a look around",
	"have a hamburger!"
}
for i,coupon in pairs(coupons) do
	if tonumber(coupon.plu) then
		if tonumber(coupon.to) or 0 > os.time() then
			table.insert(current, coupon)
		else
			table.insert(archived, coupon)
		end
	else
		table.insert(extra, coupon)
	end
end
local sort_f = function(a,b)
	local a = tonumber(a.plu) or math.huge
	local b = tonumber(b.plu) or math.huge
	return a<b
end
table.sort(current, sort_f)
table.sort(archived, sort_f)
table.sort(extra, sort_f)
write[====[
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<title>Slurger - Free burgerking coupons!</title>
		<style>
			body {
				padding: 0 0;
				margin: 0 0;
				color: #333;
				font-family: sans-serif;
			}
			.modal {
				max-width: 700px;
				background-color: #EEE;
				margin: 20px auto;
				padding: 20px 30px;
				border-radius: 6px;
			}
			.motd {
				font-size: 125%;
				font-style: italic;
			}
			.modal img {
				align: center;
			}
			.clear {
				clear: both;
			}
			.coupons {
				padding-top: 30px;
			}
			.coupon {
				border-top: 1px solid #ccc;
				padding-top: 10px;
				text-align:center;
			}

			.coupon h3 {
				font-size: 3em;
				font-weight: normal;

			}

			@media only screen and (max-width: 500px) {
				.coupon img {
					width: 100%;
				}
			}
			@media only screen and (min-width: 500px) {
				.coupon h3 {
					float: left;
					margin: 0;
					line-height:296px;
				}
				.coupon img {
					float: right;
					height: 286px;
				}
			}

		</style>
	</head>
	<body>
		<div class="modal">
			<h1>Slurger2</h1>
			<p class="motd" title="MOTD (motto of the day)">]====]write_esc( motds[math.random(1, #motds)])write[====[</p>
			<p>
				This site has a list of burgerking coupons.<br>
				To use them, tell the cashier PLU of the coupon.
			</p>
			<p>The source and some documentation is available on <a href="https://github.com/max1220/slurger">github</a>.</p>

			<div class="coupons clear">
				<h2>Current coupons:</h2>
				]====]  for i, coupon in pairs(current) do write[====[
				<div class="coupon clear">
					<h3>]====]write_esc( coupon.plu )write[====[</h3>
					<img src="]====]write_esc( coupon.local_image_286 )write[====[" alt="]====]write_esc( tostring(coupon.plu) )write[====[">
				</div>
				]====]  end write[====[
			</div>
			]====]  if #archived > 0 then write[====[
			<div class="coupons clear">
				<h2>Archived coupons:</h2>
				<p>These coupons are expired, but should work anyway:</p>
				<div class="coupons">
					]====]  for i, coupon in pairs(archived) do write[====[
					<img src="]====]write_esc( coupon.local_image_286 )write[====[" alt="]====]write_esc( tostring(coupon.plu) )write[====[">
					]====]  end write[====[
				</div>
			</div>
			]====]  end write[====[
			]====]  if #extra > 0 then write[====[
			<div class="coupons clear">
				<h2>Extra coupons:</h2>
				<p>These coupons don't have a numerical PLU.</p>
				<div class="coupons clear">
					]====]  for i, coupon in pairs(extra) do write[====[
					<div class="coupon clear">
						<h3>]====]write_esc( coupon.plu )write[====[</h3>
						<img src="]====]write_esc( coupon.local_image_286 )write[====[" alt="]====]write_esc( tostring(coupon.plu) )write[====[">
					</div>
					]====]  end write[====[
				</div>
			</div>
			]====]  end write[====[
			<div class="clear"></div>
		</div>
	</body>
</html>
]====] end