local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local shape = require("gears").shape
local util = require("util")
local wibox = require("wibox")

local dpi = beautiful.xresources.apply_dpi
local container = wibox.container
local layout = wibox.layout
local widget = wibox.widget

local module = {}
local rainbow, volume, music, kblayout

local function cal_embed(calw, flag)
  if flag == "focus" then
    local markup = util.bold(calw:get_text())
    calw:set_markup(markup)

    return widget({
      calw,
      shape = function(cr, width, height) shape.partially_rounded_rect(cr, width, height, false, true, false, true, 5) end,
      fg = "#000000",
      bg = util.sel_color,
      widget = container.background
    })
  end

  if flag == "header" or flag == "monthheader" or flag == "yearheader" then
    local markup = util.bold(calw:get_text())
    calw:set_markup(markup)
  end

  return calw
end

local function create_actions(n)
  return widget({
    notification = n,
    base_layout = widget({
      spacing = dpi(5),
      layout = layout.flex.horizontal
    }),
    widget_template = {
      {
        {
          id = "text_role",
          align = "center",
          font = beautiful.notification_font,
          widget = widget.textbox
        },
        margins = dpi(2),
        widget = container.margin
      },
      bg = "#384751",
      shape = function(cr, width, height) shape.partially_rounded_rect(cr, width, height, true, false, true, false, dpi(5)) end,
      widget = container.background
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
      widget = container.background
    }
  end

  return widget({
    layout = layout.flex.horizontal,
    forced_height = dpi(5),
    table.unpack(parts)
  })
end

local function create(n)
  naughty.layout.box({
    notification = n,
    position = "top_right",
    border_width = 0,
    shape = function(cr, width, height) shape.partially_rounded_rect(cr, width, height, true, false, true, false, dpi(20)) end,
    widget_template = {
      {
        {
          {
            {
              n.icon and {
                forced_height = dpi(42),
                widget = naughty.widget.icon
              },
              margins = dpi(8),
              widget = container.margin
            },
            bg = "#1a2026",
            widget = container.background
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
                  widget = n.message == 0 and widget.calendar.month or widget.calendar.year
                },
                layout = layout.fixed.vertical
              },
              margins = dpi(8),
              widget = container.margin
            },
            bg = "#232d35",
            widget = container.background
          },
          {
            rainbow,
            visible = #n.actions > 0,
            widget = container.background
          },
          #n.actions > 0 and {
            {
              create_actions(),
              margins = dpi(10),
              widget = container.margin
            },
            bg = "#1a2026",
            widget = container.background
          },
          layout = layout.fixed.vertical
        },
        strategy = "min",
        width = dpi(220),
        widget = container.constraint
      },
      strategy = "max",
      height = beautiful.notification_maxwidth,
      widget = container.constraint
    }
  })
end

function module.setup()
  rainbow = create_rainbow()
  naughty.connect_signal("request::display", create)

  local kl = awful.widget.keyboardlayout()
  kl:connect_signal("widget::redraw_needed", function()
    kblayout = module.show(kblayout, "keyboard", "Keyboard layout:", kl.widget.text)
  end)
end

function module.create(icon, title, message, timeout)
  return naughty.notification({
    icon = util.get_icon_dir(icon),
    title = util.bold(title),
    message = message,
    timeout = timeout
  })
end

function module.show(notify, icon, title, message, timeout)
  if not notify or notify._private.is_destroyed or notify.is_expired then
    return module.create(icon, title, message, timeout)
  end

  notify.icon = util.get_icon_dir(icon)
  notify.title = util.bold(title)
  notify.message = message
  notify.timeout = timeout

  return notify
end

function module.mpd(out, icon)
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

    music = module.show(music, icon, artist, song)
  else
    music = module.show(music, "toggle", "Music player:", status == "paused" and status or "stopped")
  end
end

function module.muted()
  awful.spawn.easy_async_with_shell("pactl list sinks | grep 'Mute:' | awk '{print $2}'", function(out)
    if out == "no\n" then
      volume = module.show(volume, "volume", "Volume:", "unmuted")
    else
      volume = module.show(volume, "muted", "Volume:", "muted")
    end
  end)
end

function module.volume(icon)
  awful.spawn.easy_async_with_shell("pactl list sinks | grep '^[[:space:]]Volume:' | awk '{print $5}'", function(out)
    volume = module.show(volume, icon, "Volume:", string.gsub(out, "\n", ""))
  end)
end

function module.toggle()
  music = module.show(music, "toggle", "Music player:", "stopped")
end

return module
