local awful = require("awful")
local dpi = require("beautiful.xresources").apply_dpi
local shape = require("gears").shape
local util = require("util")
local wibox = require("wibox")

local container = wibox.container
local layout = wibox.layout
local widget = wibox.widget

local module = {}
local btns = {}
local count, cur, name

local function update(btn, hover)
  local frame = btn:get_children_by_id("frame")[1]
  frame.border_color = hover and btn.color or "#282b31"

  local icon = btn:get_children_by_id("icon")[1]
  local text = util.span(btn.symbol, (btn.urgent or hover) and btn.color or "#e4e4e4")
  icon.markup = text
end

local function set(idx)
  update(btns[cur], false)
  update(btns[idx], true)
  cur = idx
end

local function prev()
  set(cur > 1 and cur - 1 or count)
end

local function next()
  set(cur < count and cur + 1 or 1)
end

local function notify(mods)
  module.hide()

  local t = { alt = false, ctrl = false, shift = false }

  for _, mod in ipairs(mods) do
    if mod == "Mod1" then
      t.alt = true
    end
    if mod == "Control" then
      t.ctrl = true
    end
    if mod == "Shift" then
      t.shift = true
    end
  end

  awesome.emit_signal("menu::" .. name, cur, t)
end

local function hilight(btn)
  if btn.idx == cur then return end

  update(btns[cur], false)
  update(btn, true)
  cur = btn.idx

  btn.cursor = "hand1"
end

local function create_btn(idx, color)
  local btn = wibox({
    ontop = true,
    type = "menu",
    shape = function(cr, width, height) shape.rounded_rect(cr, width, height, dpi(25)) end,
  })

  btn:setup({
    {
      id = "frame",
      shape = function(cr, width, height) shape.rounded_rect(cr, width, height, dpi(14)) end,
      border_width = dpi(10),
      bg = "#282b31",
      widget = container.background
    },
    {
      id = "icon",
      font = "CaskaydiaCove Nerd Font 35",
      align = "center",
      widget = widget.textbox
    },
    layout = layout.stack
  })

  btn:connect_signal("mouse::enter", hilight)
  btn:connect_signal("mouse::move", hilight)
  btn:connect_signal("button::press", function(_, _, _, button, mods)
    if button == awful.button.names.LEFT then
      notify(mods)
    else
      module.hide()
    end
  end)

  btn.idx = idx
  btn.color = color
  return btn
end

local function key_loop()
  keygrabber.run(function(mods, key, event)
    if event == "release" then return end

    if #key == 1 then
      local idx = tonumber(key)
      if idx and idx > 0 then
        cur = idx
        notify(mods)
      end
    elseif key == "Left" or key == "Down" then
      prev()
    elseif key == "Right" or key == "Up" then
      next()
    elseif key == "Home" then
      if cur > 1 then
        set(1)
      end
    elseif key == "End" then
      if cur < count then
        set(count)
      end
    elseif key == "Prior" then
      local idx = cur - math.floor(count / 2)
      if idx > 1 then
        set(idx)
      else
        set(1)
      end
    elseif key == "Next" then
      local idx = cur + math.floor(count / 2)
      if idx < count then
        set(idx)
      else
        set(count)
      end
    elseif key == "Escape" or key == "Menu" then
      module.hide()
    elseif key == "Return" then
      notify(mods)
    end
  end)
end

local function append_mouse_bindings()
  awful.mouse.append_global_mousebindings({
    awful.button({}, awful.button.names.LEFT, module.hide),
    awful.button({}, awful.button.names.RIGHT, module.menu),
    awful.button({}, awful.button.names.MIDDLE, module.hide),
    awful.button({}, awful.button.names.SCROLL_UP, module.scroll_up),
    awful.button({}, awful.button.names.SCROLL_DOWN, module.scroll_down),
    awful.button({}, 8, module.power)
  })
end

local function create_btns()
  local palette = util.get_rainbow()

  for i = 1, 9 do
    btns[i] = create_btn(i, palette[i % #palette + 1])
  end
end

function module.setup()
  create_btns()
  append_mouse_bindings()
end

function module.show(signal, symbols, urgent)
  local geo_s = mouse.screen.geometry
  local geo_w = {
    x = geo_s.x + (geo_s.width - #symbols * dpi(135) + dpi(20)) / 2,
    y = geo_s.y + (geo_s.height - dpi(115)) / 2,
    width = dpi(115),
    height = dpi(115)
  }

  cur = 1
  count = #symbols
  name = signal

  for i = 1, count do
    btns[i].screen = mouse.screen
    btns[i].symbol = symbols[i]
    btns[i].urgent = false
    btns[i]:geometry(geo_w)
    geo_w.x = geo_w.x + dpi(135)
  end

  if urgent then
    for _, v in ipairs(urgent) do
      btns[v].urgent = true
    end
  end

  for i = 1, count do
    update(btns[i], i == 1)
    btns[i].visible = true
  end

  key_loop()
end

function module.hide()
  if not btns[1].visible then
    return false
  end

  keygrabber.stop()
  update(btns[cur], false)

  for i = 1, count do
    btns[i].visible = false
  end

  return true
end

function module.scoll_up(s)
  if btns[1].visible then
    next()
  else
    awful.tag.viewnext(s)
  end
end

function module.scroll_down(s)
  if btns[1].visible then
    prev()
  else
    awful.tag.viewprev(s)
  end
end

return module
