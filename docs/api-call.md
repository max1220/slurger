# Burgerking API

### This page explains how we use the burgerking API.

## getCoupons
URL (Germany):
```https://www.burgerking.de/de/de/getCoupons/$2y$10$lMF/mOz7BqqVlAdzL0hvVuTF2WJqxACdATIVCteknYh2genKPuuHu```

A request to this URL returns a JSON, describing the currently available
coupons. Each item in the returned list contains the following fields:
(Used is if the item is used in the App)



 Field        | Used  | Type       | Description
--------------|-------|------------|-------------
key           | no    | String     | Seems to be an internal identifier?
id            | no    | Int        | Unique coupon/menu ID?
title         | yes   | String     | Title of coupon. For coupons the same as description. Usually is a small description of the items/menu and price info.
image_286     | maybe | URL        | Coupon image (Resolution is 286x286)
image_429     | maybe | URL        | Coupon image (Resolution is 429x429)
image_572     | maybe | URL        | Coupon image(Resolution is 572x572)
image_858     | maybe | URL        | Coupon image (Resolution is 858x858)
image_modDate | no    | Timestamp  | Image modification date(Used for caching)
description   | yes   | String     | For coupons, the same as the title. See above!
plu           | yes   | String/Int | PLU of coupon, as used by the cashiers. For certain coupons(Coupon of the month) this is just a string.
from          | yes   | Timestamp  | Valid since
to            | yes   | Timestamp  | Expiration date
newto         | no    | Timestamp  | New until ...



All timestamps are Unix timestamps.

All URLs are relative to https://www.burgerking.de/.

newto might be Null.
