local awful = require("awful")
local gears = require("gears")

local M = {}

M.tag_colors = { "#8ecb15", "#cb9a15", "#d75f00", "#ff0000", "#cb15c9", "#6f15cb", "#15b4cb", "#5edcb4" }
M.sel_color = "#dc461d"
M.alt_color = "#dc9c1d"

function M.day()
  return tonumber(os.date("%d"))
end

function M.icon_path(icon)
  local dir = gears.filesystem.get_configuration_dir()
  return dir .. "icons/" .. icon .. ".png"
end

function M.bold(s)
  if s then
    return "<b>" .. s .. "</b>"
  end
end

function M.color_text(text, color)
  return "<span foreground='" .. color .. "'>" .. text .. "</span>"
end

function M.rainbow()
  local clrs = M.tag_colors
  local shift = M.day() % #clrs

  local palette = {}
  for i = 1, #clrs do
    palette[i] = clrs[(i + shift) % #clrs + 1]
  end
  return palette
end

local function get_term(cmd)
  local ret = "kitty -1"
  if cmd then
    ret = ret .. " -e " .. cmd
  end
  return ret
end

function M.term(cmd)
  awful.spawn(get_term(cmd))
end

function M.spawn(cmd, mods)
  if mods.ctrl then
    awful.spawn(cmd)
  end
  awful.spawn(cmd)
end

function M.set_ddcutil(option)
  local bright, contrast = 0, 0

  if option == 2 then
    bright = 20
    contrast = 20
  elseif option == 3 then
    bright = 40
    contrast = 40
  elseif option == 4 then
    bright = 60
    contrast = 60
  elseif option == 5 then
    bright = 80
    contrast = 70
  elseif option == 6 then
    bright = 100
    contrast = 80
  end

  awful.spawn.easy_async("ddcutil setvcp 10 " .. bright, function()
    awful.spawn("ddcutil setvcp 12 " .. contrast)
  end)
end

function M.set_nvidia(option)
  local bright, contrast = 0, 0

  if option == 1 then
    bright = -1
    contrast = -1
  elseif option == 2 then
    bright = -0.6
    contrast = -0.6
  elseif option == 3 then
    bright = -0.2
    contrast = -0.2
  end

  local cmd = "nvidia-settings"
  local rgbs = { "Red", "Green", "Blue" }

  for _, color in ipairs(rgbs) do
    cmd = cmd .. " -a [DPY:LVDS-0]/" .. color .. "Brightness=" .. bright
    cmd = cmd .. " -a [DPY:LVDS-0]/" .. color .. "Contrast=" .. contrast
  end
  awful.spawn(cmd)
end

return M
