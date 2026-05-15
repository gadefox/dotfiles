local awful = require("awful")
local rulcl = require("ruled").client

local module = {}
local gcr_props = {
  floating = true,
  ontop = true,
  placement = awful.placement.centered
}

local function add_props(base, extra)
  local target = {}

  for k, v in pairs(base) do
    target[k] = v
  end
  for k, v in pairs(extra) do
    target[k] = v
  end

  return target
end

local rules = {
  {
    rule = {},
    properties = { screen = awful.screen.preferred }
  },
  {
    rule_any = { class = { "Gcr-prompter" } },
    properties = gcr_props
  },
  {
    rule_any = { type = { "dialog" }, class = { "Galculator", "Xephyr" } },
    properties = add_props(gcr_props, { titlebars_enabled = true })
  }
}

function module.setup()
  rulcl.connect_signal("request::rules", function()
    for _, rule in ipairs(rules) do
      rulcl.append_rule(rule)
    end
  end)

  client.connect_signal("manage", function(c)
    c:activate({ context = "manage", raise = true })
  end)

  client.connect_signal("mouse::enter", function(c)
    c:activate({ context = "mouse_enter", raise = true })
  end)
end

return module
