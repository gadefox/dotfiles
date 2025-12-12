local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local util = require("util")

local M = {}

local function create_close(c)
  local close = wibox.widget({
    {
      forced_width = 10,
      forced_height = 10,
      shape = gears.shape.circle,
      bg = util.alt_color,
      widget = wibox.container.background
    },
    top = 2,
    bottom = 2,
    left = 8,
    right  = 6,
    widget  = wibox.container.margin
  })

  close:connect_signal("button::press", function() c:kill() end)
  return close
end

local function create_title(c)
  local title = awful.titlebar(c, { bg = "#29353b" })

  title:setup({
    nil,
    {
      align = "center",
      buttons = {
        awful.button({}, 1, function() c:activate({ context = "titlebar", action = "mouse_move" }) end),
        awful.button({}, 3, function() c:activate({ context = "titlebar", action = "mouse_resize" }) end)
      },
      widget = awful.titlebar.widget.titlewidget(c),
    },
    create_close(c),
    layout = wibox.layout.align.horizontal
  })
end

function M.setup()
  client.connect_signal("request::titlebars", create_title)
end

return M
