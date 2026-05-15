local awful = require("awful")
local dpi = require("beautiful.xresources").apply_dpi
local shape = require("gears").shape
local util = require("util")
local wibox = require("wibox")

local container = wibox.container
local layout = wibox.layout
local widget = wibox.widget

local module = {}

local function create_close(c)
  local close = widget({
    {
      forced_width = dpi(10),
      forced_height = dpi(10),
      shape = shape.circle,
      bg = util.alt_color,
      widget = container.background
    },
    left = dpi(8),
    right  = dpi(6),
    top = dpi(2),
    bottom = dpi(2),
    widget  = container.margin
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
    layout = layout.align.horizontal
  })
end

function module.setup()
  client.connect_signal("request::titlebars", create_title)
end

return module
