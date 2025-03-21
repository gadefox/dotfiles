local awful = require("awful")
local dpi = require("beautiful.xresources").apply_dpi
local gears = require("gears")
local wibox = require("wibox")

local theme = {}
theme.day = os.date("%d") - 1

function theme.get_icon_path(icon)
  return debug.getinfo(1).source:match("@?(.*/)") .. "icons/" .. icon .. ".png"
end

function theme.bold(s)
  if s then
    return "<b>" .. s .. "</b>"
  end
end

-- rainbow colors
theme.rainbow_colors = {}

local colors = { "#8ecb15", "#cb9a15", "#d75f00", "#ff0000", "#cb15c9", "#6f15cb", "#15b4cb", "#5edcb4" }
local shift = theme.day % #colors
local dst = 1

for src = shift + 1, #colors do
  theme.rainbow_colors[dst] = colors[src]
  dst = dst + 1
end
for src = 1, shift do
  theme.rainbow_colors[dst] = colors[src]
  dst = dst + 1
end

-- wallpaper
theme.wallpaper_prefix = "/usr/local/share/images/wallpaper"

function theme.set_wallpaper(screen)
  awful.wallpaper({
    screen = screen,
    widget = {
      image = theme.wallpaper_prefix .. theme.wallpaper_index .. ".jpg",
      widget = wibox.widget.imagebox
    }
  })
end

awful.spawn.easy_async_with_shell("ls " .. theme.wallpaper_prefix .. "*.jpg | wc -l", function(out)
  theme.wallpaper_index = math.floor(theme.day % out)
  theme.wallpaper_max = out

  screen.connect_signal("request::wallpaper", function(s)
    theme.set_wallpaper(s)
  end)
end)

-- beautiful
local beautiful = require("beautiful")

beautiful.init({
  useless_gap = 1,  -- the gap between clients
  calendar_font = "Roboto Mono 11",
  notification_font = "Roboto Mono 11",
  notification_max_width = dpi(850)
})

-- tags
tag.connect_signal("request::default_layouts", function()
  awful.layout.append_default_layouts({
    awful.layout.suit.fair,
    awful.layout.suit.max,
    awful.layout.suit.floating
  })
end)

-- rules
local ruled = require("ruled")

ruled.client.connect_signal("request::rules", function()
  ruled.client.append_rule({
    rule = { },
    properties = {
      focus = awful.client.focus.filter,
      raise = true,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen
    }
  })
end)

client.connect_signal("mouse::enter", function(c)
  c:activate({
    context = "mouse_enter",
    raise = false
  })
end)

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
  arc.bg = length == 0 and "#00000000" or (back and "#888a85a0" or theme.rainbow_colors[(length % #theme.rainbow_colors) + 1])

  local icon = wilock:get_children_by_id("icon")[1]
  icon.markup = fail and color_text("󱗑", theme.rainbow_colors[5]) or "󰍁"
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
  s.wilock = wibox({
    screen = s,
    ontop = true,
    type = "splash",
    bg = "#000000a0"
  })
  if s == screen.primary then
    s.wilock:setup({
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
    })
  end
end

-- launcher
local wibtns = {}
local wicount, wicur, wisignal

local function btn_update(wibtn, hover)
  local frame = wibtn:get_children_by_id("frame")[1]
  frame.border_color = hover and wibtn.color or "#282b31"

  local icon = wibtn:get_children_by_id("icon")[1]
  local text = color_text(wibtn.symbol, (wibtn.urgent or hover) and wibtn.color or "#e4e4e4")
  icon.markup = text
end

local function btn_set(cur)
  btn_update(wibtns[wicur], false)
  btn_update(wibtns[cur], true)
  wicur = cur
end

local function btn_prev()
  btn_set(wicur > 1 and wicur - 1 or wicount)
end

local function btn_next()
  btn_set(wicur < wicount and wicur + 1 or 1)
end

local function btns_hide()
  if not wibtns[1].visible then
    return false
  end

  keygrabber.stop()
  btn_update(wibtns[wicur], false)

  for i = 1, wicount do
     wibtns[i].visible = false
  end

  return true
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
  local wibtn = wibox({
    ontop = true,
    type = "menu",
    shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, dpi(25)) end,
  })
  wibtn:setup({
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
  })

  wibtn:connect_signal("mouse::enter", btn_hilight)
  wibtn:connect_signal("mouse::move", btn_hilight)

  wibtn:buttons({
    awful.button({}, awful.button.names.LEFT, btn_signal),
    awful.button({}, awful.button.names.RIGHT, btns_hide),
    awful.button({}, awful.button.names.MIDDLE, btns_hide)
  })

  wibtn.color = color
  return wibtn
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
    elseif key == "Left" or key == "Down" then
      btn_prev()
    elseif key == "Right" or key == "Up" then
      btn_next()
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

  btn_key_loop()
end

for i = 1, 9 do
  local color = i ~= 8 and i % #theme.rainbow_colors or 8
  wibtns[i] = btn_create(theme.rainbow_colors[color])
  wibtns[i].idx = i
end

local function scroll_up(screen)
  if wibtns[1].visible then
    btn_next()
  else
    awful.tag.viewnext(screen)
  end
end

local function scroll_down(screen)
  if wibtns[1].visible then
    btn_prev()
  else
    awful.tag.viewprev(screen)
  end
end

function theme.launch_power()
  if not btns_hide() then
    theme.launch("power", { "󰐥", "󰜉", "󰍁", "󰗽", "󱣲" })
  end
end

function theme.launch_menu()
  theme.launch("menu", { "󰊲", "󰉕", "󰧭", "", "󰖟", "󰽴", "", "" })
end

awful.mouse.append_global_mousebindings({
  awful.button({}, awful.button.names.LEFT, btns_hide),
  awful.button({}, awful.button.names.RIGHT, function()
    if not btns_hide() then
      theme.launch_menu()
    end
  end),
  awful.button({}, awful.button.names.MIDDLE, btns_hide),
  awful.button({}, awful.button.names.SCROLL_UP, scroll_up),
  awful.button({}, awful.button.names.SCROLL_DOWN, scroll_down),
  awful.button({}, 8, theme.launch_power)
})

-- wibar
local function tag_update(item, tag, index)
  if tag.selected then
    item.top.bg = theme.rainbow_colors[index]
    item.bottom.bg = theme.rainbow_colors[index]
  elseif tag.urgent then
    item.top.bg = "#e4e4e4"
    item.bottom.bg = "#00000000"
  elseif #tag:clients() > 0 then
    item.top.bg = theme.rainbow_colors[index]
    item.bottom.bg = "#00000000"
  else
    item.top.bg = "#00000000"
    item.bottom.bg = "#00000000"
 end
end

function theme.tags_create(s)
  s.taglist = awful.widget.taglist({
    screen = s,
    filter = awful.widget.taglist.filter.all,
    buttons = {
      awful.button({}, awful.button.names.LEFT, function(t)
        if btns_hide() then
          return
        end

        if t == t.screen.selected_tag then
          awful.tag.history.restore()
        else
          t:view_only()
        end
      end),
      awful.button({}, awful.button.names.RIGHT, function(t)
        if btns_hide() then
          return
        end

       local clients = t:clients()

        for i = 1, #clients do
          local c = clients[i]
          c:kill()
        end
      end),
      awful.button({}, awful.button.names.MIDDLE, btns_hide),
      awful.button({}, awful.button.names.SCROLL_UP, function(t) scroll_up(t.screen) end),
      awful.button({}, awful.button.names.SCROLL_DOWN, function(t) scroll_down(t.screen) end),
      awful.button({}, 8, theme.launch_power)
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
  })
  s.wibar = awful.wibar({
    screen = s,
    visible = true,
    ontop = false,
    type = "dock",
    position = "top",
    height = dpi(7),
    bg = theme.opacity
  })
  s.wibar:setup({
    widget = s.taglist
  })
end

-- notifications
local naughty = require("naughty")

local rainbow_widget = wibox.widget({
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
})

local function cal_embed(widget, flag)
  if flag == "focus" then
    local markup = theme.bold(widget:get_text())
    widget:set_markup(markup)

    return wibox.widget({
      widget,
      shape = function(cr, width, height) gears.shape.partially_rounded_rect(cr, width, height, false, true, false, true, 5) end,
      fg = "#000000",
      bg = "#dc461d",
      widget = wibox.container.background
    })
  end

  if flag == "header" or flag == "monthheader" or flag == "yearheader" then
    local markup = theme.bold(widget:get_text())
    widget:set_markup(markup)
  end

  return widget
end

naughty.connect_signal("request::display", function(n)
  local actions = wibox.widget({
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
          rainbow_widget,
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
            rainbow_widget,
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
        width = dpi(220),
        widget = wibox.container.constraint
      },
      strategy = "max",
      height = beautiful.notification_maxwidth,
      widget = wibox.container.constraint
    }
  })
end)

function theme.create_notify(icon, title, message, timeout)
  return naughty.notification({
    icon = theme.get_icon_path(icon),
    title = theme.bold(title),
    message = message,
    timeout = timeout
  })
end

function theme.show_notify(widget, icon, title, message, timeout)
  if not widget or widget._private.is_destroyed or widget.is_expired then
    return theme.create_notify(icon, title, message, timeout)
  end

  widget.icon = theme.get_icon_path(icon)
  widget.title = theme.bold(title)
  widget.message = message
  widget.timeout = timeout

  return widget
end

return theme
