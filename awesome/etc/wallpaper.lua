local awful = require("awful")
local wibox = require("wibox")
local util = require("util")

local M = {}
local max, cur
local dir = "/usr/local/share/images/wallpaper"

function M.set(s)
  awful.wallpaper({
    screen = s,
    widget = {
      image = dir .. cur .. ".jpg",
      widget = wibox.widget.imagebox
    }
  })
end

function M.setup()
  awful.spawn.easy_async_with_shell("ls " .. dir .. "*.jpg | wc -l", function(out)
    max = tonumber(out)
    cur = math.floor(util.day() % max)

    screen.connect_signal("request::wallpaper", M.set)
  end)
end

return M
