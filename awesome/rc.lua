require("awful.autofocus")
local gears = require("gears")

-- focus and swap
local focus = require("focus")
focus.init()

-- tags
local awful = require("awful")
local theme = require("theme")

awful.screen.connect_for_each_screen(function(s)
  awful.tag(
    { "1", "2", "3", "4", "5", "6", "7", "8" },
    s,
    awful.layout.suit.fair)

  theme.lock_create(s)
  theme.tags_create(s)
end)

tag.connect_signal("request::default_layouts", function()
  awful.layout.append_default_layouts {
    awful.layout.suit.fair
  }
end)

client.connect_signal("mouse::enter", function(c)
  c:activate {
    context = "mouse_enter",
    raise = false
  }
end)

-- custom notifications
local notif_kb, notif_v, notif_m

local function bold(s)
  return "<b>" .. s .. "</b>"
end

local kb_layout = awful.widget.keyboardlayout()

kb_layout:connect_signal("widget::redraw_needed", function ()
  notif_kb = theme.notify({
      title = bold("Keyboard layout:"),
      message = kb_layout.widget.text,
      icon = theme.icons .. "keyboard.png",
    }, notif_kb)
end)

local function msg_volume(icon)
  awful.spawn.easy_async_with_shell("pactl list sinks | grep '^[[:space:]]Volume:' | awk '{print $5}'", function(out)
    notif_v = theme.notify({
      title = bold("Volume:"),
      message = string.gsub(out, "\n", ""),
      icon = theme.icons .. icon,
    }, notif_v)
  end)
end

local function msg_muted()
  awful.spawn.easy_async_with_shell("pactl list sinks | grep 'Mute:' | awk '{print $2}'", function(out)
    local message, icon

    if out == "no\n" then
      message = "unmuted"
      icon = "volume.png"
    else
      message = "muted"
      icon = "muted.png"
    end

    notif_v = theme.notify({
      title = bold("Volume:"),
      message = message,
      icon = theme.icons .. icon,
    }, notif_v)
  end)
end

local function msg_mpd_stop(msg)
  notif_m = theme.notify({
    title = bold("Music player:"),
    message = msg,
    icon = theme.icons .. "playerctl_toggle.png"
  }, notif_m)
end

local function msg_mpd(out, icon)
  local status = out:match("%[(.*)%]")

  if status == "playing" then
    local artist = out:match("^(.*) %- ")
    if not artist or not #artist then
      artist = "N/A"
    end

    local song = out:match(" %- (.*)\n%[")
    if not song or not #song then
      song = "N/A"
    end

    notif_m = theme.notify({
      title = bold(artist),
      message = song,
      icon = theme.icons .. icon,
    }, notif_m)
  else
    msg_mpd_stop(status == "paused" and status or "stopped")
  end
end

local function msg_now()
  theme.notify({
    title = bold("Now:"),
    message = os.date("%a %d %b, %H:%M"),
    icon = theme.icons .. "alarm.png",
  })
end

-- rules
local ruled = require("ruled")

ruled.client.connect_signal("request::rules", function()
  ruled.client.append_rule {
    rule = { },
    properties = {
      focus = awful.client.focus.filter,
      raise = true,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen
    }
  }
end)

-- key bindings
local function term(cmd)
  local ret = "st"
  if cmd then
    ret = ret .. " -e " .. cmd
  end
  return ret
end

awesome.connect_signal("launch::dev", function(option)
  if option == 1 then
    awful.spawn(term())
  elseif option == 2 then
    awful.spawn(term("nvim"))
  elseif option == 3 then
    awful.spawn("nemiver")
  end
end)

awesome.connect_signal("launch::file", function(option)
  if option == 1 then
    awful.spawn("pcmanfm")
  elseif option == 2 then
    awful.spawn(term("nnn"))
  elseif option == 3 then
    awful.spawn(term("mc"))
  elseif option == 4 then
    awful.spawn("xarchiver")
  end
end)

awesome.connect_signal("launch::image", function(option)
  if option == 1 then
    awful.spawn("gpick")
  elseif option == 2 then
    awful.spawn("gimp")
  end
end)

awesome.connect_signal("launch::light", function(option)
  local bright0, contrast0, bright1, contrast1

  if option == 1 then
    bright0 = -1
    contrast0 = -1
    bright1 = 0
    contrast1 = 0
  elseif option == 2 then
    bright0 = -0.9
    contrast0 = -0.9
    bright1 = 20
    contrast1 = 20
  elseif option == 3 then
    bright0 = -0.3
    contrast0 = -0.3
    bright1 = 40
    contrast1 = 40
  elseif option == 4 then
    bright0 = 0
    contrast0 = 0
    bright1 = 60
    contrast1 = 60
  elseif option == 5 then
    bright0 = 0
    contrast0 = 0
    bright1 = 80
    contrast1 = 70
  elseif option == 6 then
    bright0 = 0
    contrast0 = 0
    bright1 = 100
    contrast1 = 80
  end

  local rgb_names = { "Red", "Green", "Blue" }
  local cmd = "ddcutil setvcp 10 " .. bright1 .. "; sleep 1; ddcutil setvcp 12 " .. contrast1 .. "; sleep 1; nvidia-settings"
  for _, color in ipairs(rgb_names) do
    cmd = cmd .. " -a [DPY:LVDS-0]/" .. color .. "Brightness=" .. bright0
    cmd = cmd .. " -a [DPY:LVDS-0]/" .. color .. "Contrast=" .. contrast0
  end
  awful.spawn.with_shell(cmd)
end)

awesome.connect_signal("launch::office", function(option)
  if option == 1 then
    awful.spawn("swriter")
  elseif option == 2 then
    awful.spawn("scalc")
  end
end)

awesome.connect_signal("launch::scrot", function(option)
  if option == 1 then
    awful.spawn("scrot")
  elseif option == 2 then
    awful.spawn("slop-shot")
  end
end)

awesome.connect_signal("launch::settings", function(option)
  if option == 1 then
    awful.spawn.easy_async_with_shell("ddcutil -t getvcp 10 | awk '{print $4}'", function(out)
      local urgent

      local vcp = tonumber(out)
      if vcp < 10 then
        urgent = 1
      elseif vcp < 30 then
        urgent = 2
      elseif vcp < 50 then
        urgent = 3
      elseif vcp < 70 then
        urgent = 4
      elseif vcp < 90 then
        urgent = 5
      else
        urgent = 6
      end

      theme.launch("light", { "󱩍", "󱩐", "󱩑", "󱩓", "󱩕", "󰛨" }, { urgent })
    end)
  elseif option == 2 then
    awful.spawn("lxrandr")
  end
end)

local function timer()
  theme.launch("timer", { "󱑋", "󱑌", "󱑍", "󱑎", "󱑏", "󱑐", "󱑓", "󱑕" })
end

awesome.connect_signal("launch::tool", function(option)
  if option == 1 then
    timer()
  elseif option == 2 then
    theme.launch("scrot", { "", "󰩭" })
  elseif option == 3 then
    awful.spawn(term("calc"))
  elseif option == 4 then
    awful.spawn(term("htop"))
  end
end)

awesome.connect_signal("launch::web", function(option)
  if option == 1 then
    awful.spawn("qutebrowser")
  elseif option == 2 then
    awful.spawn("firefox")
  elseif option == 3 then
    awful.spawn("evolution")
  elseif option == 4 then
    awful.spawn(term("irssi"))
  elseif option == 5 then
    awful.spawn("transmission-gtk")
  end
end)

awesome.connect_signal("launch::music", function(option)
  if option == 1 then
    awful.spawn(term("ncmpc"))
  elseif option == 2 then
    awful.spawn("pavucontrol")
  end
end)

awesome.connect_signal("launch::info", function(option)
  if option == 1 then
    msg_now()
  elseif option == 2 then
    awful.spawn("pavucontrol")
  end
end)

awesome.connect_signal("launch::timer", function(option)
  if option == 1 then
    awful.spawn("timer 300")
  elseif option == 2 then
    awful.spawn("timer 600")
  elseif option == 3 then
    awful.spawn("timer 900")
  elseif option == 4 then
    awful.spawn("timer 1200")
  elseif option == 5 then
    awful.spawn("timer 1500")
  elseif option == 6 then
    awful.spawn("timer 1800")
  elseif option == 7 then
    awful.spawn("timer 2700")
  elseif option == 8 then
    awful.spawn("timer 3300")
  end
end)

awesome.connect_signal("launch::app", function(option)
  if option == 1 then
    theme.launch("info", { "󱑒", "" })
  elseif option == 2 then
    theme.launch("file", { "", "󱗁", "󰖔", "" })
  elseif option == 3 then
    theme.launch("office", { "󱎒", "󱎏" })
  elseif option == 4 then
    theme.launch("image", { "󰈋", "󱇤" })
  elseif option == 5 then
    theme.launch("dev", { "", "󱥈", "" })
  elseif option == 6 then
    theme.launch("web", { "󰘯", "󰈹", "", "", "󰄠" })
  elseif option == 7 then
    theme.launch("music", { "󰝚", "󰋍" })
  elseif option == 8 then
    theme.launch("tool", { "󰔛", "󰭪", "󱖦", "" })
  elseif option == 9 then
    theme.launch("settings", { "󰃟", "󰍺" })
  end
end)

awesome.connect_signal("launch::sys", function(option)
  if option == 1 then
    awful.spawn.with_shell("/sbin/poweroff")
  elseif option == 2 then
    awful.spawn.with_shell("/sbin/reboot")
  elseif option == 3 then
    theme.lock()
  elseif option == 4 then
    awesome.quit()
  elseif option == 5 then
    awesome.restart()
  end
end)

awful.keyboard.append_global_keybindings {
  awful.key({ }, "XF86PowerOff", function() theme.launch("sys", { "󰐥", "󰜉", "󰍁", "󰗽", "󱣲" }) end,
    { description = "quit", group = "awesome" }),
  awful.key({ "Mod4" }, "Escape", theme.lock,
    { description = "quit", group = "awesome" }),

  awful.key({ "Mod4" }, "Up", function() awful.screen.focus_relative(1) end,
    { description = "next", group = "screen" }),
  awful.key({ "Mod4" }, "Down", function() awful.screen.focus_relative(-1) end,
    { description = "previous", group = "screen" }),

  awful.key({ "Mod4" }, "Left", awful.tag.viewprev,
    { description = "previous", group = "tag" }),
  awful.key({ "Mod4" }, "Right", awful.tag.viewnext,
    { description = "next", group = "tag" }),
  awful.key({ "Mod4" }, "Home", function() awful.screen.focused().tags[1]:view_only() end,
    { description = "first", group = "tag" }),
  awful.key({ "Mod4" }, "End", function()
    local tags = awful.screen.focused().tags
    tags[#tags]:view_only()
  end,
    { description = "last", group = "tag" }),
  awful.key({ "Mod4" }, "BackSpace", awful.tag.history.restore,
    { description = "back & forth", group = "tag" }),
  awful.key({ "Mod4", "Shift" }, "minus", function () awful.tag.incgap(-1, nil) end,
    {description = "decrement gap", group = "tags" }),
  awful.key({ "Mod4" }, "minus", function () awful.tag.incgap(1, nil) end,
    {description = "increment gaps", group = "tags" }),
  awful.key({ "Mod4" }, "space", awful.client.urgent.jumpto,
    { description = "jump to urgent client", group = "client" }),

  awful.key({ "Mod4" }, "Return", function() awful.spawn(term()) end,
    { description = "open a terminal", group = "launch" }),
  awful.key({ }, "Menu", function() theme.launch("app", { "", "󰉕", "󰧭", "", "󰘦", "󰖟", "󰽴", "", "" }) end,
    { description = "show the menubar", group = "launch" }),
  awful.key({ }, "Print", function() awful.spawn("scrot") end,
    { description = "printscreen", group = "launch" }),
  awful.key({ "Shift" }, "Print", function()
    theme.notify({
      title = bold("Screenshot:"),
      message = "select a window or rectangle",
      icon = theme.icons .. "screenshot.png",
      timeout = 2
    })
    awful.spawn.with_shell("slop-shot")
  end,
    { description = "printscreen area", group = "launch" }),

  awful.key({ }, "XF86Mail", function() awful.spawn("evolution") end,
    { description = "email", group = "launch" }),
  awful.key({ }, "XF86HomePage", function() awful.spawn("qutebrowser") end,
    { description = "browser", group = "launch" }),
  awful.key({ }, "XF86Messenger", function() awful.spawn(term("irssi")) end,
    { description = "messenger", group = "launch" }),
  awful.key({ }, "XF86Tools", function() awful.spawn(term("ncmpc")) end,
    { description = "browser", group = "launch" }),
  awful.key({ }, "XF86Launch5", function() awful.spawn(term("nnn")) end,
    { description = "terminal fm", group = "launch" }),
  awful.key({ }, "XF86Launch6", function() awful.spawn("pcmanfm") end,
    { description = "file manager", group = "launch" }),
  awful.key({ }, "XF86Launch9", function() awful.spawn(term("htop")) end,
    { description = "process monitor", group = "launch" }),
  awful.key({ }, "XF86Favorites", function() timer() end,
    { description = "timer", group = "launch" }),
  awful.key({ }, "XF86Documents", function() awful.spawn(term("nvim")) end,
    { description = "neovim", group = "launch" }),
  awful.key({ }, "XF86Calculator", function() awful.spawn(term("calc")) end,
    { description = "calc", group = "launch" }),

  awful.key({ }, "XF86AudioLowerVolume", function()
    awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ -5%")
    msg_volume("volume1.png")
  end,
    { description = "lower", group = "volume" }),
  awful.key({ }, "XF86AudioRaiseVolume", function()
    awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ +5%")
    msg_volume("volume.png")
 end,
    { description = "raise", group = "volume" }),
  awful.key({ }, "XF86AudioMute", function()
    awful.spawn.with_shell("pactl set-sink-mute @DEFAULT_SINK@ toggle")
    msg_muted()
  end,
    { description = "(un)mute", group = "volume" }),

  awful.key({ }, "XF86AudioPlay", function()
    awful.spawn.easy_async("mpc toggle", function(out)
      msg_mpd(out, "playerctl_toggle.png")
    end)
  end,
    { description = "play", group = "music" }),
  awful.key({ }, "XF86AudioPrev", function()
    awful.spawn.easy_async("mpc prev", function(out)
      msg_mpd(out, "playerctl_prev.png")
    end)
  end,
    { description = "previous", group = "music" }),
  awful.key({ }, "XF86AudioNext", function()
    awful.spawn.easy_async("mpc next", function(out)
      msg_mpd(out, "playerctl_next.png")
    end)
  end,
    { description = "next", group = "music" }),
  awful.key({ }, "XF86AudioStop", function()
    awful.spawn.with_shell("mpc stop")
    msg_mpd_stop("stopped")
  end,
    { description = "stop", group = "music" })
}

-- start
awful.spawn("dex -a")
