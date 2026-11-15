local awful = require("awful")
local dpi = require("beautiful.xresources").apply_dpi
local shape = require("gears").shape
local util = require("util")
local wibox = require("wibox")

local container = wibox.container
local layout = wibox.layout
local widget = wibox.widget

local module = {}
local pwd

local function animate(fail, back)
  local dirs = { "north", "west", "south", "east" }
  local length = #pwd
  local wilock = screen.primary.wilock

  local rotate = wilock:get_children_by_id("rotate")[1]
  rotate.direction = dirs[(length % 4) + 1]

  local arc = wilock:get_children_by_id("arc")[1]
  local palette = util.get_rainbow()
  arc.bg = length == 0 and "#00000000" or (back and "#888a85a0" or palette[(length % #palette) + 1])

  local icon = wilock:get_children_by_id("icon")[1]
  icon.markup = fail and util.span("󱗑", palette[5]) or "󰍁"
end

local function show(visible)
  for s in screen do
    s.wilock.visible = visible
    awful.placement.maximize(s.wilock)
  end
end

local function loop()
  keygrabber.run(function(_, key, event)
    if event == "release" then return end

    if key == "Escape" then
      if #pwd > 0 then
        pwd = ""
        animate(false, false)
      end
    elseif key == "BackSpace" then
      if #pwd > 0 then
        pwd = string.sub(pwd, 1, -2)
        animate(false, true)
      end
    elseif key == "Return" then
      local pam = require("libpam")

      if pam.auth(pwd) then
        show(false)
        keygrabber.stop()
      else
        pwd = ""
        animate(true, false)
      end
    elseif #key == 1 then
      pwd = pwd .. key
      animate(false, false)
    end
  end)
end

local function create(s)
  s.lock = wibox({
    screen = s,
    ontop = true,
    type = "splash",
    bg = "#000000a0"
  })

  s.lock:setup({
    {
      {
        {
          id = "arc",
          shape = function(cr, width, height) shape.arc(cr, width, height, dpi(10), 0, math.pi / 2, true, true) end,
          widget = container.background
        },
        id = "rotate",
        widget = container.rotate
      },
      {
        id = "icon",
        align = "center",
        font = "CaskaydiaCove Nerd Font 45",
        widget = widget.textbox
      },
      forced_width = dpi(180),
      forced_height = dpi(180),
      layout = layout.stack
    },
    widget = container.place
  })
end

function module.screen()
  pwd = ""
  animate(false, false)
  show(true)
  loop()
end

function module.setup(s)
  if s == screen.primary then
    create(s)
  end
end

return module
