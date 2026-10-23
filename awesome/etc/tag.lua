local awful = require("awful")
local dpi = require("beautiful.xresources").apply_dpi
local menu = require("menu")
local menus = require("menus")
local util = require("util")
local wibox = require("wibox")

local container = wibox.container
local layout = wibox.layout

local module = {}

local function update(item, tag, index, _)
  local palette = util.get_rainbow()

  if tag.selected then
    item.top.bg = palette[index]
    item.bottom.bg = palette[index]
  elseif tag.urgent then
    item.top.bg = "#e4e4e4"
    item.bottom.bg = "#00000000"
  elseif #tag:clients() > 0 then
    item.top.bg = palette[index]
    item.bottom.bg = "#00000000"
  else
    item.top.bg = "#00000000"
    item.bottom.bg = "#00000000"
 end
end

local function create_tags(s)
  local tags = {}

  for i = 1, 8 do
    table.insert(tags, tostring(i))
  end
  awful.tag(tags, s, awful.layout.suit.fair)
end

local function create_taglist(s)
  s.taglist = awful.widget.taglist({
    screen = s,
    filter = awful.widget.taglist.filter.all,
    buttons = {
      awful.button({}, awful.button.names.LEFT, function(t)
        if menu.hide() then return end
        if t == t.screen.selected_tag then
          awful.tag.history.restore()
        else
          t:view_only()
        end
      end),
      awful.button({}, awful.button.names.RIGHT, function(t)
        if menu.hide() then return end
        local clients = t:clients()
        for i = 1, #clients do
          local c = clients[i]
          c:kill()
        end
      end),
      awful.button({}, awful.button.names.MIDDLE, menu.hide),
      awful.button({}, awful.button.names.SCROLL_UP, function(t) menu.scroll_up(t.screen) end),
      awful.button({}, awful.button.names.SCROLL_DOWN, function(t) menu.scroll_down(t.screen) end),
      awful.button({}, 8, menus.power)
    },
    layout = layout.flex.horizontal,
    widget_template = {
      {
        id = "top",
        forced_height = dpi(5),
        widget = container.background
      },
      {
        id = "bottom",
        forced_height = dpi(2),
        widget = container.background
      },
      layout = layout.fixed.vertical,
      create_callback = update,
      update_callback = update
    }
  })
end

local function create_bar(s)
  s.wibar = awful.wibar({
    screen = s,
    visible = true,
    ontop = false,
    type = "dock",
    position = "top",
    height = dpi(7),
  })

  s.wibar:setup({ widget = s.taglist })
end

function module.setup()
  awful.screen.connect_for_each_screen(function(s)
    create_tags(s)
    create_taglist(s)
    create_bar(s)
  end)

  tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
      awful.layout.suit.fair,
      awful.layout.suit.max,
      awful.layout.suit.floating
    })
  end)
end

function module.first()
  local screen = awful.screen.focused()
  screen.tags[1]:view_only()
end

function module.last()
  local screen = awful.screen.focused()
  screen.tags[#screen.tags]:view_only()
end

return module
