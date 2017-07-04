# slurger2

 This project came to be after discovering that the burgerking Android app
 gets you 'free' burgerking coupons(at the expense of some of your personal
 data). After some MITMing with my phone, I figured out how the app gets the
 coupon information from the burgerking server, and build a website around it,
 so you don't have to use the app anymore. As it turns out, the JSON the server
 sends to the app also contains a validity timespan for each coupon, so the app
 can cache images of upcomming coupons befor they are valid, and hide 'to old'
 coupons. The coupon codes seem to stay valid for the cashiers afterwards
 anyway, so to maximize coupon yield, this application will keep track of all
 coupons, technicly valid or not, but show appropriate warnings to the user.
 This application has been written as portable and light as possible, so that
 even a non-rooted android phone can run it, making the circle complete:
 In it's minimal configuration, it has no external dependency exept any
 version of lua and either one of lua-socket, wget or curl installed. Even the
 wget version from busybox will suffice.



## config.lua

 User-configurable options are in here. This file is commented. After each
 config key, there should be a ',', to conform with Lua's table syntax.



## Templates

 slurger2 uses this templating system: [lua-template](https://github.com/dannote/lua-template),
 with a few bugfixes etc. and integrated into this project.
 The template will be passed a list of coupons to render.

 To compile a template of your own, use `./templatec.lua <input file> -o <output name>.lua`.



## Synopsis

 `./slurger2.lua [options]`

 You can provide options using the following syntax:

 `--<key>=<value>`

 &lt;key&gt; and &lt;value&gt; are the same as in the configuraion file, and each possible
 key is described in the default config.


### tl;dr: It will most likely work as expected. just run `./slurger2.lua`
