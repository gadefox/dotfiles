local awful = require("awful")
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi
local gears = require("gears")
local naughty = require("naughty")
local wibox = require("wibox")
local util = require("util")

local M = {}
local rainbow, kblayout, volume, music, layout

local function cal_embed(widget, flag)
  if flag == "focus" then
    local markup = util.bold(widget:get_text())
    widget:set_markup(markup)

    return wibox.widget({
      widget,
      shape = function(cr, width, height) gears.shape.partially_rounded_rect(cr, width, height, false, true, false, true, 5) end,
      fg = "#000000",
      bg = util.sel_color,
      widget = wibox.container.background
    })
  end

  if flag == "header" or flag == "monthheader" or flag == "yearheader" then
    local markup = util.bold(widget:get_text())
    widget:set_markup(markup)
  end

  return widget
end

local function create_actions(n)
  return wibox.widget({
    notification = n,
    base_layout = wibox.widget({
      spacing = dpi(5),
      layout = wibox.layout.flex.horizontal
    }),
    widget_template = {
      {
        {
          id = "text_role",
          align = "center",
          font = beautiful.notification_font,
          widget = wibox.widget.textbox
        },
        margins = dpi(2),
        widget = wibox.container.margin
      },
      bg = "#384751",
      shape = function(cr, width, height) gears.shape.partially_rounded_rect(cr, width, height, true, false, true, false, dpi(5)) end,
      widget = wibox.container.background
    },
    style = {
      underline_normal = false
    },
    widget = naughty.list.actions
  })
end

local function create_rainbow()
  local lookup = { 5, 6, 7, 1, 2, 4 }
  local parts = {}

  for k, v in ipairs(lookup) do
    parts[k] = {
      bg = util.tag_colors[v],
      widget = wibox.container.background
    }
  end

  return wibox.widget({
    layout = wibox.layout.flex.horizontal,
    forced_height = dpi(5),
    table.unpack(parts)
  })
end

local function create(n)
  naughty.layout.box({
    notification = n,
    position = "top_right",
    border_width = 0,
    shape = function(cr, width, height) gears.shape.partially_rounded_rect(cr, width, height, true, false, true, false, dpi(20)) end,
    widget_template = {
      {
        {
          {
            {
              n.icon and {
                forced_height = 42,
                widget = naughty.widget.icon
              },
              margins = dpi(8),
              widget = wibox.container.margin
            },
            bg = "#1a2026",
            widget = wibox.container.background
          },
          rainbow,
          {
            {
              {
                n.title and {
                  align = "center",
                  widget = naughty.widget.title
                },
                type(n.message) == "string" and {
                  align = "center",
                  widget = naughty.widget.message
                } or {
                  date = os.date("*t"),
                  fn_embed = cal_embed,
                  widget = n.message == 0 and wibox.widget.calendar.month or wibox.widget.calendar.year
                },
                layout = wibox.layout.fixed.vertical
              },
              margins = dpi(8),
              widget = wibox.container.margin
            },
            bg = "#232d35",
            widget = wibox.container.background
          },
          {
            rainbow,
            visible = #n.actions > 0,
            widget = wibox.container.background
          },
          #n.actions > 0 and {
            {
              create_actions(),
              margins = dpi(10),
              widget = wibox.container.margin
            },
            bg = "#1a2026",
            widget = wibox.container.background
          },
          layout = wibox.layout.fixed.vertical
        },
        strategy = "min",
        width = dpi(220),
        widget = wibox.container.constraint
      },
      strategy = "max",
      height = beautiful.notification_maxwidth,
      widget = wibox.container.constraint
    }
  })
end

function M.setup()
  rainbow = create_rainbow()
  naughty.connect_signal("request::display", create)

  kblayout = awful.widget.keyboardlayout()
  kblayout:connect_signal("widget::redraw_needed", function()
    layout = M.show(layout, "keyboard", "Keyboard layout:", kblayout.widget.text)
  end)
end

function M.create(icon, title, message, timeout)
  return naughty.notification({
    icon = util.icon_path(icon),
    title = util.bold(title),
    message = message,
    timeout = timeout
  })
end

function M.show(widget, icon, title, message, timeout)
  if not widget or widget._private.is_destroyed or widget.is_expired then
    return M.create(icon, title, message, timeout)
  end

  widget.icon = util.icon_path(icon)
  widget.title = util.bold(title)
  widget.message = message
  widget.timeout = timeout

  return widget
end

function M.mpd(out, icon)
  local status = out:match("%[(.*)%]")

  if status == "playing" then
    local artist = out:match("^(.*) %- ")
    if not artist or not #artist then
      artist = "N/A"
    end

    local song = out:match(" %- (.*)\n%[")
    if not song or not #song then
      song = "N/A"
    end

    music = M.show(music, icon, artist, song)
  else
    music = M.show(music, "toggle", "Music player:", status == "paused" and status or "stopped")
  end
end

function M.muted()
  awful.spawn.easy_async_with_shell("pactl list sinks | grep 'Mute:' | awk '{print $2}'", function(out)
    if out == "no\n" then
      volume = M.show(volume, "volume", "Volume:", "unmuted")
    else
      volume = M.show(volume, "muted", "Volume:", "muted")
    end
  end)
end

function M.volume(icon)
  awful.spawn.easy_async_with_shell("pactl list sinks | grep '^[[:space:]]Volume:' | awk '{print $5}'", function(out)
    volume = M.show(volume, icon, "Volume:", string.gsub(out, "\n", ""))
  end)
end

function M.toggle()
  music = M.show(music, "toggle", "Music player:", "stopped")
end

return M
