require("awful.autofocus")

local awful = require("awful")
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi
local gears = require("gears")
local keys = require("keys")
local lock = require("lock")
local menu = require("menu")
local menus = require("menus")
local notify = require("notify")
local rules = require("rules")
local swap = require("swap")
local tag = require("tag")
local title = require("title")
local util = require("util")
local wallpaper = require("wallpaper")

beautiful.init({
  useless_gap = 1,
  calendar_font = "Roboto Mono 11",
  notification_font = "Roboto Mono 11",
  notification_max_width = dpi(850),
  snap_border_width = 4,
  snap_bg = util.alt_color,
  snap_shape = gears.shape.rectangle
})

keys.setup()
lock.setup()
menu.setup()
menus.setup()
notify.setup()
rules.setup()
swap.setup()
tag.setup()
title.setup()
wallpaper.setup()

awful.spawn("dex -a")
notify.create("calendar", nil, 0, 15)
