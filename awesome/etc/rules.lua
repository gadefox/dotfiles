local awful = require("awful")
local ruled = require("ruled")

local M = {}

local function append_rules()
  ruled.client.append_rule({
    rule = {},
    properties = {
      screen = awful.screen.preferred,
      raise  = true
    }
  })

  ruled.client.append_rule({
    rule_any = {
      type = { "dialog" },
      role = { "dialog" },
      class = { "Galculator" }
    },
    properties = {
      floating = true,
      titlebars_enabled = true,
      placement = awful.placement.centered
    }
  })

  ruled.client.append_rule({
    rule_any = {
      class = { "Gcr-prompter" }
    },
    properties = {
      floating = true,
      placement = awful.placement.centered
    }
  })
end

function M.setup()
  ruled.client.connect_signal("request::rules", append_rules)

  client.connect_signal("mouse::enter", function(c)
    c:activate({ context = "mouse_enter", raise = false })
  end)
end

return M
