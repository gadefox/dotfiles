local awful = require("awful")
local util = require("util")
local widget = require("wibox").widget

local module = {}
local max, cur
local dir = "/usr/local/share/images/wallpaper"

function module.set(s)
  awful.wallpaper({
    screen = s,
    widget = {
      image = dir .. cur .. ".jpg",
      widget = widget.imagebox
    }
  })
end

function module.setup()
  awful.spawn.easy_async_with_shell("ls " .. dir .. "*.jpg | wc -l", function(out)
    max = tonumber(out)
    cur = math.floor(util.get_day() % max)

    screen.connect_signal("request::wallpaper", module.set)
  end)
end

return module
