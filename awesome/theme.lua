local awful = require("awful")
local dpi = require("beautiful.xresources").apply_dpi
local gears = require("gears")
local wibox = require("wibox")

local theme = {}
theme.day = os.date("%d") - 1
theme.icons = debug.getinfo(1).source:match("@?(.*/)") .. "icons/"

-- wallpaper
theme.wpdir = "/usr/local/share/images/wallpaper"

awful.spawn.easy_async_with_shell("ls " .. theme.wpdir .. "*.jpg | wc -l", function(out)
  theme.wpidx = math.floor(theme.day % out)
  theme.wpcnt = out

  screen.connect_signal("request::wallpaper", function(s)
    awful.wallpaper {
      screen = s,
      widget = {
        image = theme.wpdir .. theme.wpidx .. ".jpg",
        widget = wibox.widget.imagebox
      }
    }
  end)
end)

local function shift_colors()
  local colors = {
    "#8ecb15",
    "#cb9a15",
    "#d75f00",
    "#ff0000",
    "#cb15c9",
    "#6f15cb",
    "#15b4cb",
    "#5edcb4"
  }
  local shift = theme.day % #colors
  local dst = 1
  theme.colors = {}

  for src = shift + 1, #colors do
    theme.colors[dst] = colors[src]
    dst = dst + 1
  end
  for src = 1, shift do
    theme.colors[dst] = colors[src]
    dst = dst + 1
  end
end

-- beautiful
local beautiful = require("beautiful")

beautiful.init {
  useless_gap = 1,
  notification_font = "Roboto Mono 11" }

-- lock screen
local dirs = { "north", "west", "south", "east" }
local pwd

local function color_text(text, color)
  return "<span foreground='" .. color .. "'>" .. text .. "</span>"
end

local function lock_animate(fail, back)
  local length = #pwd
  local wilock = screen.primary.wilock

  local rotate = wilock:get_children_by_id("rotate")[1]
  rotate.direction = dirs[(length % 4) + 1]

  local arc = wilock:get_children_by_id("arc")[1]
  arc.bg = length == 0 and "#00000000" or (back and "#888a85a0" or theme.colors[(length % #theme.colors) + 1])

  local icon = wilock:get_children_by_id("icon")[1]
  icon.markup = fail and color_text("󱗑", theme.colors[5]) or "󰍁"
end

local function lock_show(show)
  for s in screen do
    s.wilock.visible = show
    awful.placement.maximize(s.wilock)
  end
end

local function lock_loop()
  keygrabber.run(function(_, key, event)
    if event == "release" then return end

    if key == "Escape" then
      if #pwd > 0 then
        pwd = ""
        lock_animate(false, false)
      end
    elseif key == "BackSpace" then
      if #pwd > 0 then
        pwd = string.sub(pwd, 1, -2)
        lock_animate(false, true)
      end
    elseif key == "Return" then
      local pam = require("libpam")

      if pam.auth(pwd) then
        lock_show(false)
        keygrabber.stop()
      else
        pwd = ""
        lock_animate(true, false)
      end
    elseif #key == 1 then
      pwd = pwd .. key
      lock_animate(false, false)
    end
  end)
end

function theme.lock()
  pwd = ""
  lock_animate(false)
  lock_show(true)
  lock_loop()
end

function theme.lock_create(s)
  s.wilock = wibox {
    screen = s,
    ontop = true,
    type = "splash",
    bg = "#000000a0"
  }
  if s == screen.primary then
    s.wilock:setup {
      {
        {
          {
            id = "arc",
            shape = function(cr, width, height) gears.shape.arc(cr, width, height, dpi(10), 0, math.pi / 2, true, true) end,
            widget = wibox.container.background
          },
          id = "rotate",
          widget = wibox.container.rotate
        },
        {
          id = "icon",
          align = "center",
          font = "CaskaydiaCove Nerd Font 45",
          widget = wibox.widget.textbox
        },
        forced_width = dpi(180),
        forced_height = dpi(180),
        layout = wibox.layout.stack
      },
      widget = wibox.container.place
    }
  end
end

-- wibar
local function tag_update(item, tag, index)
  if tag.selected then
    item.top.bg = theme.colors[index]
    item.bottom.bg = theme.colors[index]
  elseif tag.urgent then
    item.top.bg = "#e4e4e4"
    item.bottom.bg = "#00000000"
  elseif #tag:clients() > 0 then
    item.top.bg = theme.colors[index]
    item.bottom.bg = "#00000000"
  else
    item.top.bg = "#00000000"
    item.bottom.bg = "#00000000"
 end
end

function theme.tags_create(s)
  s.taglist = awful.widget.taglist {
    screen = s,
    filter = awful.widget.taglist.filter.all,
    buttons = {
      awful.button({}, awful.button.names.LEFT, function(t)
        if t == t.screen.selected_tag then
          awful.tag.history.restore()
        else
          t:view_only()
        end
      end),
      awful.button({}, awful.button.names.SCROLL_UP, function(t)
        awful.tag.viewprev(t.screen)
      end),
      awful.button({}, awful.button.names.SCROLL_DOWN, function(t)
        awful.tag.viewnext(t.screen)
      end)
    },
    layout = wibox.layout.flex.horizontal,
    widget_template = {
      {
        id = "top",
        forced_height = dpi(5),
        widget = wibox.container.background
      },
      {
        id = "bottom",
        forced_height = dpi(2),
        widget = wibox.container.background
      },
      layout = wibox.layout.fixed.vertical,
      create_callback = function(self, tag, index, _)
        tag_update(self, tag, index)
      end,
      update_callback = function(self, tag, index, _)
        tag_update(self, tag, index)
      end
    }
  }
  s.wibar = awful.wibar {
    screen = s,
    visible = true,
    ontop = false,
    type = "dock",
    position = "top",
    height = dpi(7),
    bg = theme.opacity
  }
  s.wibar:setup {
    widget = s.taglist
  }
end

-- notifications
local naughty = require("naughty")
shift_colors()

local rainbow = wibox.widget {
  {
    bg = "#cb15c9",
    widget = wibox.container.background
  },
  {
    bg = "#6f15cb",
    widget = wibox.container.background
  },
  {
    bg = "#15b4cb",
    widget = wibox.container.background
  },
  {
    bg = "#8ecb15",
    widget = wibox.container.background
  },
  {
    bg = "#cb9a15",
    widget = wibox.container.background
  },
  {
    bg = "#ff0000",
    widget = wibox.container.background
  },
  forced_height = dpi(5),
  layout = wibox.layout.flex.horizontal
}

naughty.connect_signal("request::display", function(n)
  local actions = wibox.widget {
    notification = n,
    base_layout = wibox.widget {
      spacing = 10,
      layout = wibox.layout.flex.horizontal
    },
    widget_template = {
      {
        {
          id = "text_role",
          align = "center",
          font = beautiful.notification_font,
          widget = wibox.widget.textbox
        },
        margins = dpi(7),
        widget = wibox.container.margin
      },
      bg = "#232d35",
      widget = wibox.container.background
    },
    style = {
      underline_normal = false,
      underline_selected = true
    },
    widget = naughty.list.actions
  }

  naughty.layout.box {
    notification = n,
    position = "top_right",
    border_width = 0,
    shape = function(cr, width, height) gears.shape.partially_rounded_rect(cr, width, height, true, false, true, false, dpi(20)) end,
    widget_template = {
      {
        {
          {
            {
              {
                n.icon and {
                  widget = naughty.widget.icon
                },
                widget = wibox.container.place
              },
              margins = dpi(7),
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
                {
                  align = "center",
                  widget = naughty.widget.message
                },
                layout = wibox.layout.fixed.vertical
              },
              margins = dpi(12),
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
              actions,
              margins = dpi(10),
              widget = wibox.container.margin
            },
            bg = "#1a2026",
            widget = wibox.container.background
          },
          layout = wibox.layout.fixed.vertical
        },
        strategy = "min",
        width = dpi(160),
        widget = wibox.container.constraint
      },
      strategy = "max",
      width = dpi(350),
      height = dpi(200),
      widget = wibox.container.constraint
    }
  }
end)

function theme.notify(args, n)
  if not n or n._private.is_destroyed or n.is_expired then
    return naughty.notification(args)
  end

  n.icon = args.icon
  n.timeout = args.timeout
  n.title = args.title
  n.message = args.message
  return n
end

-- launcher wibox
local wibtns = {}
local wicount, wicur, wisignal
local wileft = nil

local function btn_update(wibtn, hover)
  local frame = wibtn:get_children_by_id("frame")[1]
  frame.border_color = hover and wibtn.color or "#282b31"

  local icon = wibtn:get_children_by_id("icon")[1]
  local text = color_text(wibtn.symbol, (wibtn.urgent or hover) and wibtn.color or "#e4e4e4")
  icon.markup = text
end

local function btns_hide()
  keygrabber.stop()

  root._buttons({})
  awful.mouse.remove_client_mousebinding(wileft)

  for s in screen do
    s.wibar:_buttons({})
  end

  btn_update(wibtns[wicur], false)

  for i = 1, wicount do
     wibtns[i].visible = false
  end
end

local function btn_signal()
  btns_hide()
  awesome.emit_signal("launch::" .. wisignal, wicur)
end

local function btn_hilight(w)
  if w.idx == wicur then return end

  btn_update(wibtns[wicur], false)
  btn_update(w, true)
  wicur = w.idx

  w.cursor = "hand1"
end

local function btn_create(color)
  local wibtn = wibox {
    ontop = true,
    type = "menu",
    shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, dpi(25)) end,
  }
  wibtn:setup {
    {
      id = "frame",
      shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, dpi(14)) end,
      border_width = dpi(10),
      bg = "#282b31",
      widget = wibox.container.background
    },
    {
      id = "icon",
      font = "CaskaydiaCove Nerd Font 35",
      align = "center",
      widget = wibox.widget.textbox
    },
    layout = wibox.layout.stack
  }

  wibtn:connect_signal("mouse::enter", btn_hilight)
  wibtn:connect_signal("mouse::move", btn_hilight)

  wibtn:buttons(awful.button({}, awful.button.names.LEFT, btn_signal))

  wibtn.color = color
  return wibtn
end

for i = 1, 9 do
  local color = i ~= 8 and i % #theme.colors or 8
  wibtns[i] = btn_create(theme.colors[color])
  wibtns[i].idx = i
end

local function btn_set(cur)
  btn_update(wibtns[wicur], false)
  btn_update(wibtns[cur], true)
  wicur = cur
end

local function btn_key_loop()
  keygrabber.run(function(_, key, event)
    if event == "release" then return end

    if #key == 1 then
      local idx = tonumber(key)
      if idx and idx > 0 then
        wicur = idx
        btn_signal()
      end
    elseif key == "Left" or key == "Up" then
      btn_set(wicur > 1 and wicur - 1 or wicount)
    elseif key == "Right" or key == "Down" then
      btn_set(wicur < wicount and wicur + 1 or 1)
    elseif key == "Home" then
      if wicur > 1 then
        btn_set(1)
      end
    elseif key == "End" then
      if wicur < wicount then
        btn_set(wicount)
      end
    elseif key == "Prior" then
      local idx = wicur - math.floor(wicount / 2)
      if idx > 1 then
        btn_set(idx)
      else
        btn_set(1)
      end
    elseif key == "Next" then
      local idx = wicur + math.floor(wicount / 2)
      if idx < wicount then
        btn_set(idx)
      else
        btn_set(wicount)
      end
    elseif key == "Escape" or key == "Menu" then
      btns_hide()
    elseif key == "Return" then
      btn_signal()
    end
  end)
end

function theme.launch(signal, symbols, urgent)
  local geo_s = mouse.screen.geometry
  local geo_w = {
    x = geo_s.x + (geo_s.width - #symbols * dpi(135) + dpi(20)) / 2,
    y = geo_s.y + (geo_s.height - dpi(115)) / 2,
    width = dpi(115),
    height = dpi(115)
  }

  wicur = 1
  wicount = #symbols
  wisignal = signal

  for i = 1, wicount do
    wibtns[i].screen = mouse.screen
    wibtns[i].symbol = symbols[i]
    wibtns[i].urgent = false
    wibtns[i]:geometry(geo_w)
    geo_w.x = geo_w.x + dpi(135)
  end

  if urgent then  -- optional parameter
    for _, v in ipairs(urgent) do
      wibtns[v].urgent = true
    end
  end

  for i = 1, wicount do
    btn_update(wibtns[i], i == 1)  -- select first wibox (wicur == 1)
    wibtns[i].visible = true
  end

  if not wileft then
    wileft = awful.button({}, awful.button.names.LEFT, btns_hide)
  end

  root.buttons(wileft)
  awful.mouse.append_client_mousebinding(wileft)

  for s in screen do
    s.wibar:buttons(wileft)
  end

  btn_key_loop()
end

return theme
