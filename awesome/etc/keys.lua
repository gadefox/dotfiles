local awful = require("awful")
local lock = require("lock")
local menus = require("menus")
local notify = require("notify")
local tag = require("tag")
local util = require("util")

local module = {}

function module.setup()
  awful.keyboard.append_global_keybindings({
    awful.key({}, "XF86PowerOff", menus.power,                                                    { description = "quit", group = "awesome" }),
    awful.key({ "Mod4" }, "Escape", lock.screen,                                                  { description = "quit", group = "awesome" }),
    awful.key({ "Mod4" }, "Up", function() awful.screen.focus_relative(1) end,                    { description = "next", group = "screen" }),
    awful.key({ "Mod4" }, "Down", function() awful.screen.focus_relative(-1) end,                 { description = "previous", group = "screen" }),
    awful.key({ "Mod4" }, "Left", awful.tag.viewprev,                                             { description = "previous", group = "tag" }),
    awful.key({ "Mod4" }, "Right", awful.tag.viewnext,                                            { description = "next", group = "tag" }),
    awful.key({ "Mod4" }, "Home", tag.first,                                                      { description = "first", group = "tag" }),
    awful.key({ "Mod4" }, "End", tag.last,                                                        { description = "last", group = "tag" }),
    awful.key({ "Mod4" }, "BackSpace", awful.tag.history.restore,                                 { description = "back & forth", group = "tag" }),
    awful.key({ "Mod4" }, "space", awful.client.urgent.jumpto,                                    { description = "jump to urgent client", group = "client" }),
    awful.key({ "Mod4" }, "Return", util.term,                                                    { description = "open a terminal", group = "menu" }),
    awful.key({ "Mod4" }, "q", function() if client.focus then client.focus:kill() end end,       { description = "close window", group = "client"}),

    awful.key({}, "Menu", menus.main,                                                             { description = "show menubar", group = "menu" }),
    awful.key({}, "Print", menus.scrot,                                                           { description = "printscreen", group = "menu" }),
    awful.key({}, "XF86Mail", function() awful.spawn("evolution") end,                            { description = "email", group = "menu" }),
    awful.key({}, "XF86HomePage", menus.browser,                                                  { description = "browser", group = "menu" }),
    awful.key({}, "XF86Messenger", function() util.term("irssi --home=~/.local/share/irssi") end, { description = "messenger", group = "menu" }),
    awful.key({}, "XF86Tools", function() util.term("ncmpc") end,                                 { description = "browser", group = "menu" }),
    awful.key({}, "XF86Launch5", menus.file,                                                      { description = "files", group = "menu" }),
    awful.key({}, "XF86Launch8", menus.webcam,                                                    { description = "camera", group = "menu" }),
    awful.key({}, "XF86Launch9", function() util.term("htop") end,                                { description = "process monitor", group = "menu" }),
    awful.key({}, "XF86Favorites", menus.timer,                                                   { description = "timer", group = "menu" }),
    awful.key({}, "XF86Documents", function() util.term("nvim") end,                              { description = "neovim", group = "menu" }),
    awful.key({}, "XF86Calculator", function() awful.spawn("galculator") end,                     { description = "UI calc", group = "menu" }),
    awful.key({ "Shift" }, "XF86Calculator", function() util.term("calc") end,                    { description = "CLI calc", group = "menu" }),

    awful.key({}, "XF86AudioLowerVolume", function()
      awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")
      notify.volume("volume1")
    end,                                                                                          { description = "lower", group = "volume" }),
    awful.key({}, "XF86AudioRaiseVolume", function()
      awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")
      notify.volume("volume")
    end,                                                                                          { description = "raise", group = "volume" }),
    awful.key({}, "XF86AudioMute", function()
      awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
      notify.muted()
    end,                                                                                          { description = "(un)mute", group = "volume" }),
    awful.key({}, "XF86AudioPlay", function()
      awful.spawn.easy_async("mpc toggle", function(out)
        notify.mpd(out, "music")
      end)
    end,                                                                                          { description = "play", group = "music" }),
    awful.key({}, "XF86AudioPrev", function()
      awful.spawn.easy_async("mpc prev", function(out)
        notify.mpd(out, "prev")
      end)
    end,                                                                                          { description = "previous", group = "music" }),
    awful.key({}, "XF86AudioNext", function()
      awful.spawn.easy_async("mpc next", function(out)
        notify.mpd(out, "next")
      end)
    end,                                                                                          { description = "next", group = "music" }),
    awful.key({}, "XF86AudioStop", function()
      awful.spawn("mpc stop")
      notify.toggle()
    end,                                                                                          { description = "stop", group = "music" })
  })
end

return module
