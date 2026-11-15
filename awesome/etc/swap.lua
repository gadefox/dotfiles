local awful = require("awful")
local dpi = require("beautiful.xresources").apply_dpi
local shape = require("gears").shape
local timer = require("gears").timer
local wibox = require("wibox")

local container = wibox.container
local layout = wibox.layout
local widget = wibox.widget

local module, arcs = {}, {}
local keys = { Left = 2, Right = 4, Up = 3, Down = 1 }
local edge

local function init()
  edge = nil
end

local function calc_edge()
  edge = 0

  for s in screen do
    local geo = s.geometry

    if edge < geo.x + geo.width then
      edge = geo.x + geo.width
    end
  end
end

local function calc_dist(dir, A, B)
  if dir == keys.Left then
    return A.x - B.x - B.width + math.abs(A.y - B.y + (A.height - B.height) / 2) * 0.3
  elseif dir == keys.Right then
    return B.x - A.x - A.width + math.abs(A.y - B.y + (A.height - B.height) / 2) * 0.3
  elseif dir == keys.Up then
    return A.y - B.y - B.height + math.abs(A.x - B.x + (A.width - B.width) / 2) * 0.3
  elseif dir == keys.Down then
    return B.y - A.y - A.height + math.abs(A.x - B.x + (A.width - B.width) / 2) * 0.3
  end
end

local function overlaps(a1, a2, b1, b2)
  return a2 >= b1 - 40 and b2 >= a1 - 40
end

local function is_in_dir(dir, A, B)
  if dir == keys.Left then
    if B.x + B.width > A.x then return false end
    return overlaps(A.y, A.y + A.height, B.y, B.y + B.height)
  elseif dir == keys.Right then
    if B.x < A.x + A.width then return false end
    return overlaps(A.y, A.y + A.height, B.y, B.y + B.height)
  elseif dir == keys.Up then
    if B.y + B.height > A.y then return false end
    return overlaps(A.x, A.x + A.width, B.x, B.x + B.width)
  elseif dir == keys.Down then
    if B.y < A.y + A.height then return false end
    return overlaps(A.x, A.x + A.width, B.x, B.x + B.width)
  end

  return false
end

local function get_in_dir(dir, cur, rects)
  local min = nil
  local target = nil

  for i, rect in pairs(rects) do
    if is_in_dir(dir, cur, rect) then
      local dist = calc_dist(dir, cur, rect)
      if not target or dist < min then
        target = i
        min = dist
      end
    end
  end

  return target
end

local function geometries(clients, swap)
  local geoms, scrs, left, right = {}, {}, {}, {}
  local min, max = edge, 0

  -- collect real clients
  for i, c in ipairs(clients) do
    local geo = c:geometry()

    if min > geo.x then min = geo.x end
    if max < geo.x + geo.width then max = geo.x + geo.width end

    geoms[i] = geo
    scrs[c.screen] = true
  end

  -- collect empty screens
  if swap then
    for s in screen do
      if not scrs[s] then
        local geo = s.workarea

        if min > geo.x then min = geo.x end
        if max < geo.x + geo.width then max = geo.x + geo.width end

        geoms[#geoms + 1] = geo
        clients[#geoms] = {
          fake = true,
          screen = s,
          geometry = function() return s.workarea end
        }
      end
    end
  end

  -- collect edge clients/empty screens
  for i, geo in ipairs(geoms) do
    if min == geo.x then left[#left + 1] = i end
    if max == geo.x + geo.width then right[#right + 1] = i end
  end

  -- wrap-around duplicates
  for _, i in ipairs(left) do
    local geo = geoms[i]

    geoms[#geoms + 1] = { x = max, y = geo.y, width = geo.width, height = geo.height }
    clients[#geoms] = clients[i]
  end

  for _, i in ipairs(right) do
    local geo = geoms[i]

    geoms[#geoms + 1] = { x = min - geo.width, y = geo.y, width = geo.width, height = geo.height }
    clients[#geoms] = clients[i]
  end

--  print(string.format("min=%d max=%d", min, max))
--  for i, geo in ipairs(geoms) do
--    print(string.format("%d x0=%d x1=%d y0=%d y1=%d (w=%d h=%d)", i, geo.x, geo.x + geo.width, geo.y, geo.y + geo.height, geo.width, geo.height))
--  end
  return geoms
end

local function display(cur, swap, clients, geoms)
  if not clients then
    -- geometries have changed by swapping, so refresh
    clients = awful.client.tiled()
    geoms = geometries(clients, swap)
  end

  local lookup = {}
  local geom = cur:geometry()

  for _, v in pairs(keys) do
    local idx = get_in_dir(v, geom, geoms)
    local cl = clients[idx]
    if not cl or lookup[cl] then
      arcs[v].visible = false
    else
      lookup[cl] = true
      arcs[v].visible = true
      awful.placement.centered(arcs[v], { parent = cl })
    end
  end

  awful.placement.centered(arcs[5], { parent = cur })
end

local function bydirection(dir, swap)
  if not edge then calc_edge() end

  local cur = client.focus
  local geom = cur:geometry()
  local clients = awful.client.tiled()
  local geoms = geometries(clients, swap)

  local idx = get_in_dir(dir, geom, geoms)
  if not idx then return end

  local target = clients[idx]

  if swap then
    if cur.screen == target.screen then
      cur:swap(target)
    else
      cur:move_to_tag(target.screen.selected_tag)
      client.focus = cur
    end
    timer.delayed_call(function() display(cur, swap) end)
  else
    client.focus = target
    display(target, swap, clients, geoms)
  end
end

local function hide()
  for k = 1, 5 do
    arcs[k].visible = false
  end
end

local function loop(swap)
  keygrabber.run(function(mod, key, event)
    for k, v in pairs(keys) do
      if key == k then
        if event == "press" then
          bydirection(v, swap)
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
  arcs[5].visible = true

  bydirection(dir, swap)
  loop(swap)
end

local function create_arc(idx, head, tail)
  local palette = { [0] = "#7cbb00", "#ffbb00", "#f65314", "#00a1f1" }

  return widget({
    shape = function(cr, width, height) shape.arc(cr, width, height, dpi(12), math.pi * idx / 2, math.pi * (idx + 1) / 2, head, tail) end,
    bg = palette[idx],
    widget = container.background
  })
end

local function create_arcs()
  for i = 0, 4 do
    local arc = wibox({
      width = dpi(100),
      height = dpi(100),
      ontop = true
    })
    local stack = { layout = layout.stack }

    if i == 4 then
      arc.shape = function(cr, width, height) shape.arc(cr, width, height, dpi(12), 0, math.pi * 2, false, false) end

      for k = 0, 3 do
        table.insert(stack, create_arc(k, false, false))
      end
    else
      arc.shape = function(cr, width, height) shape.arc(cr, width, height, dpi(12), math.pi * i / 2, math.pi * (i / 2 + 1), true, true) end

      table.insert(stack, create_arc(i, true,  false))
      table.insert(stack, create_arc((i + 1) % 4, false, true))
    end

    arc:setup(stack)
    arcs[i + 1] = arc
  end
end

local function append_bindings()
  local aw = {}

  for k, v in pairs(keys) do
    aw[#aw + 1] = awful.key({ "Mod4", "Control" }, k, function() handle(v, false) end, { description = "Change focus to the " .. k, group = "client" })
    aw[#aw + 1] = awful.key({ "Mod4", "Shift" }, k, function() handle(v, true) end, { description = "Move to the " .. k, group = "client" })
  end
  awful.keyboard.append_global_keybindings(aw)
end

function module.setup()
  create_arcs()
  append_bindings()
  screen.connect_signal("added", init)
  screen.connect_signal("removed", init)
end

return module
