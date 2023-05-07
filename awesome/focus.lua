local awful = require("awful")
local dpi = require("beautiful.xresources").apply_dpi
local gears = require("gears")
local theme = require("theme")
local wibox = require("wibox")

local focus, wiboxes = {}, {}
local screens, screens_inv  -- Screen order is not always geometrical, sort them

local function get_screens()
  if screens then
    return screens, screens_inv
  end

  screens = {}
  for i = 1, screen.count() do
    local geom = screen[i].geometry
    if #screens == 0 then
      screens[1] = screen[i]
    elseif geom.x < screen[screens[1]].geometry.x then
      table.insert(screens, 1, screen[i])
    else
      for j = #screens, 1, -1 do
        if geom.x > screen[screens[j]].geometry.x then
          table.insert(screens, j + 1, screen[i])
          break
        end
      end
    end
  end

  screens_inv = {}
  for k, v in ipairs(screens) do
    screens_inv[v] = k
  end

  return screens, screens_inv
end

screen.connect_signal("added", function()
  screens = nil
  screens_inv = nil
end)

screen.connect_signal("removed", function()
  screens = nil
  screens_inv = nil
end)

local function emulate_client(idx)
  return {
    is_screen = true,
    screen = idx,
    geometry = function() return screen[idx].workarea end
  }
end

local function display(cltbl, geomtbl)
  local lookup = {}
  local dirs = { "right", "left", "up", "down" }
  local ks = { 2, 4, 1, 3 }  -- we can't use the table { left = 4, right = 2, up = 1, down = 3 }
  local fc = client.focus or emulate_client(mouse.screen)

  for k, v in ipairs(ks) do
    local dir = gears.geometry.rectangle.get_in_direction(dirs[k], geomtbl, fc:geometry())
    local next = cltbl[dir]

    if next and not lookup[next] then
      wiboxes[v].visible = true
      awful.placement.centered(wiboxes[v], { parent = next })

      lookup[next] = v
   else
      wiboxes[v].visible = false
    end
  end

  wiboxes[5].visible = true
  awful.placement.centered(wiboxes[5], { parent = fc })
end

local edge = nil

local function get_rects(cltbl)
  local geomtbl, scrs, roundr, roundl = {}, {}, {}, {}

  -- Get all clients rectangle
  for i, cl in ipairs(cltbl) do
    local geo = cl:geometry()

    geomtbl[i] = geo
    scrs[screen[cl.screen or 1]] = true

    if geo.x == 0 then
      roundr[#roundr + 1] = cl
    elseif geo.x + geo.width >= edge - 2 then
      roundl[#roundl + 1] = cl
    end
  end

  --Add first client at the end to be able to rotate selection
  for _, c in ipairs(roundr) do
    local geo = c:geometry()

    geomtbl[#geomtbl + 1] = {
      x = edge,
      width = geo.width,
      y = geo.y,
      height = geo.height
    }
    cltbl[#geomtbl] = c
  end

  for _, c in ipairs(roundl) do
    local geo = c:geometry()

    geomtbl[#geomtbl + 1] = {
      x = -geo.width,
      width = geo.width,
      y = geo.y,
      height = geo.height
    }
    cltbl[#geomtbl] = c
  end

  -- Add rectangles for empty screens too
  for i = 1, screen.count() do
    if not scrs[screen[i]] then
      geomtbl[#geomtbl + 1] = screen[i].workarea
      cltbl[#geomtbl] = emulate_client(i)
    end
  end

  return geomtbl
end

local function focus_target(target, cltbl)
  -- If we found a client to focus, then do it.
  if not target then return end

  local cl = cltbl[target]
  if cl and cl.is_screen then
    client.focus = nil  --TODO Fix upstream fix
    mouse.screen = screen[cl.screen]
  else
    local old_src = client.focus and client.focus.screen

    client.focus = cltbl[((not cl and #cltbl == 1) and 1 or target)]
    client.focus:raise()
    if not old_src or client.focus.screen ~= screen[old_src] then
      mouse.coords(client.focus:geometry())
    end
  end
end

local function swap_target(target, cltbl, dir, cur)
  if target then
    -- We found a client to swap
    local other = cltbl[((not cltbl[target] and #cltbl == 1) and 1 or target)]

    if screen[other.screen] == screen[cur.screen] then
      --BUG swap doesn't work if the screen is not the same
      cur:swap(other)
    else
      cur.screen = screen[other.screen]
      cur:tags { screen[other.screen].selected_tag }  --TODO get index
    end
  else
    -- No client to swap, try to find a screen.
    local screen_geom = {}
    for i = 1, screen.count() do
      screen_geom[i] = screen[i].workarea
    end

    target = gears.geometry.rectangle.get_in_direction(dir, screen_geom, cur:geometry())
    if target and target ~= c.screen then
      cur.screen = target
      cur:tags { screen[target].selected_tag }
      cur:raise()
    end
  end

  return target
end

local function bydirection(dir, swap)
  cur = client.focus
  if not cur then
    cur = emulate_client(mouse.screen)
  end

  if not edge then
    local scrs = get_screens()
    local last_geo = screen[scrs[#scrs]].geometry
    edge = last_geo.x + last_geo.width
  end

  local cltbl = awful.client.tiled()
  local geomtbl = get_rects(cltbl)
  local target = gears.geometry.rectangle.get_in_direction(dir, geomtbl, cur:geometry())

  if swap then
    target = swap_target(target, cltbl, dir, cur)
    if target then
      -- Geometries have changed by swapping, so refresh.
      cltbl = awful.client.tiled()
      geomtbl = {}

      for i, cl in ipairs(cltbl) do
        geomtbl[i] = cl:geometry()
      end
    end
  else
    focus_target(target, cltbl)
  end

  display(cltbl, geomtbl)
end

local function hide()
  for k = 1, 5 do
    wiboxes[k].visible = false
  end
end

local keys = { up = "Up", down = "Down", left = "Left", right = "Right" }

local function loop(swap)
  keygrabber.run(function(mod, key, event)
    -- Detect the direction
    for k, v in pairs(keys) do
      if key == v then
        if event == "press" then
          bydirection(k, swap)
          return
        end
        return #mod > 0
      end
    end

    if key == "Shift_L" or key == "Shift_R" then
      swap = event == "press"
      return #mod > 0
    end

    hide()
    keygrabber.stop()
  end)
end

local function handle(dir, swap)
  bydirection(dir, swap)
  loop(swap)
end

local function create_arc(idx, round_s, round_e)
  local colors = { [0] = 1, 5, 6, 7 }  -- idx <0..3>

  return wibox.widget {
    shape = function(cr, width, height) gears.shape.arc(cr, width, height, dpi(12), math.pi * idx / 2, math.pi * (idx + 1) / 2, round_s, round_e) end,
    bg = theme.colors[colors[idx]],
    widget = wibox.container.background
  }
end

function focus.init()
  for k = 1, 4 do
    local i_s = (k + 1) % 4

    wiboxes[k] = wibox {
      width = 100,
      height = 100,
      ontop = true,
      shape = function(cr, width, height) gears.shape.arc(cr, width, height, dpi(12), math.pi * i_s / 2, math.pi * ((k + 3) % 4) / 2, true, true) end,
    }
    wiboxes[k]:setup {
      create_arc(i_s, true, false),
      create_arc((k + 2) % 4, false, true),
      layout = wibox.layout.stack
    }
  end

  wiboxes[5] = wibox {
    width = 100,
    height = 100,
    ontop = true,
    shape = function(cr, width, height) gears.shape.arc(cr, width, height, dpi(12), 0, math.pi * 2) end,
  }
  wiboxes[5]:setup {
    create_arc(0, false, false),
    create_arc(1, false, false),
    create_arc(2, false, false),
    create_arc(3, false, false),
    layout = wibox.layout.stack
  }

  local aw = {}

  for k, v in pairs(keys) do
    aw[#aw + 1] = awful.key({ "Mod4", "Control" }, v, function () handle(k, false) end,
      { description = "Change focus to the " .. k, group = "client" })
    aw[#aw + 1] = awful.key({ "Mod4", "Shift" }, v, function () handle(k, true) end,
      { description = "Move to the " .. k, group = "client" })
  end

  awful.keyboard.append_global_keybindings(aw)
end

return focus
