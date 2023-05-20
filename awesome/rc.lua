local autofocus = require("awful.autofocus")

-- focus and swap
local focus = require("focus")
focus.init()

-- wallpaper
local awful = require("awful")
local wibox = require("wibox")

screen.connect_signal("request::wallpaper", function(s)
  awful.wallpaper {
    screen = s,
    widget = {
      image = "/usr/local/share/images/wallpaper.jpg",
      widget = wibox.widget.imagebox
    }
  }
end)

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
local kb_notif, notif_v, notif_m

local function png(img)
  return debug.getinfo(1).source:match("@?(.*/)") .. "icons/" .. img .. ".png"
end

local function bold(s)
  return "<b>" .. s .. "</b>"
end

local kb_layout = awful.widget.keyboardlayout()

kb_layout:connect_signal("widget::redraw_needed", function ()
  kb_notif = theme.notify({
      title = bold("Keyboard layout:"),
      message = kb_layout.widget.text,
      icon = png("keyboard"),
    }, kb_notif)
end)

local function msg_volume(icon)
  awful.spawn.easy_async_with_shell("pactl list sinks | grep '^[[:space:]]Volume:' | awk '{print $5}'", function(out)
    notif_v = theme.notify({
      title = bold("Volume:"),
      message = string.gsub(out, "\n", ""),
      icon = png("volume" .. icon),
    }, notif_v)
  end)
end

local function msg_muted()
  awful.spawn.easy_async_with_shell("pactl list sinks | grep 'Mute:' | awk '{print $2}'", function(out)
    local message, icon

    if out == "no\n" then
      message = "unmuted"
      icon = "volume"
    else
      message = "muted"
      icon = message
    end

    notif_v = theme.notify({
      title = bold("Volume:"),
      message = message,
      icon = png(icon),
    }, notif_v)
  end)
end

local function msg_mpd_stop(msg)
  notif_m = theme.notify({
    title = bold("Music player:"),
    message = msg,
    icon = png("playerctl_toggle")
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
      icon = png(icon),
    }, notif_m)
  else
    msg_mpd_stop(status == "paused" and status or "stopped")
  end
end

local function msg_now()
  theme.notify({
    title = bold("Now:"),
    message = os.date("%a %d %b, %H:%M"),
    icon = png("alarm"),
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
  local ret = "alacritty"
  if cmd then
    ret = ret .. " -e " .. cmd
  end
  return ret
end

awesome.connect_signal("launch::dev", function(option)
  if option == 1 then
    awful.spawn("nemiver")
  end
end)

awesome.connect_signal("launch::file", function(option)
  if option == 1 then
    awful.spawn(term("nnn"))
  elseif option == 2 then
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
  local light, bright, contrast

  if option == 1 then
    light = 0
    bright = 0
    contrast = 0
  elseif option == 2 then
    light = 30
    bright = 20
    contrast = 20
  elseif option == 3 then
    light = 50
    bright = 40
    contrast = 40
  elseif option == 4 then
    light = 70
    bright = 60
    contrast = 60
  elseif option == 5 then
    light = 90
    bright = 80
    contrast = 70
  elseif option == 6 then
    light = 100
    bright = 100
    contrast = 80
  end

--  awful.spawn("light -S " .. light)
  awful.spawn("ddcutil --use-file-io setvcp 10 " .. bright)
  awful.spawn("ddcutil --use-file-io setvcp 12 " .. contrast)
end)

awesome.connect_signal("launch::office", function(option)
  if option == 1 then
    awful.spawn(term("nvim"))
  elseif option == 2 then
    awful.spawn.with_shell("swriter")
  elseif option == 3 then
    awful.spawn.with_shell("scalc")
  elseif option == 4 then
    awful.spawn.with_shell("sbase")
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
    awful.spawn.easy_async_with_shell("ddcutil --use-file-io getvcp 10 | awk '{print $9}'", function(out)
      local vcp = tonumber(string.sub(out, 1, -3))
      local urgent = {}

      if vcp < 10 then
        urgent[1] = 1
      elseif vcp < 30 then
        urgent[1] = 2
      elseif vcp < 50 then
        urgent[1] = 3
      elseif vcp < 70 then
        urgent[1] = 4
      elseif vcp < 90 then
        urgent[1] = 5
      else
        urgent[1] = 6
      end

      theme.launch("light", { "󱩍", "󱩐", "󱩑", "󱩓", "󱩕", "󰛨" }, urgent)
    end)
  elseif option == 2 then
    awful.spawn("lxrandr")
  elseif option == 3 then
    awful.spawn("dconf-editor")
  end
end)

awesome.connect_signal("launch::tool", function(option)
  if option == 1 then
    theme.launch("scrot", { "", "󰩭" })
  elseif option == 2 then
    awful.spawn.with_shell(term("calc"))
  elseif option == 3 then
    awful.spawn.with_shell("jmtpfs /media/mtp")
 elseif option == 4 then
    awful.spawn(term("htop"))
  end
end)

awesome.connect_signal("launch::web", function(option)
  if option == 1 then
    awful.spawn("qutebrowser")
  elseif option == 2 then
    awful.spawn.with_shell("xdg-open 'https://mail.google.com'")
  elseif option == 3 then
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

awesome.connect_signal("launch::app", function(option)
  if option == 1 then
    awful.spawn(term())
  elseif option == 2 then
    theme.launch("file", { "", "" })  -- 
  elseif option == 3 then
    theme.launch("office", { "", "󱎒", "󱎏", "󱘲" })
  elseif option == 4 then
    theme.launch("image", { "󰈋", "󱇤" })  -- 
  elseif option == 5 then
    theme.launch("dev", { "" })  -- 
  elseif option == 6 then
    theme.launch("web", { "󰈹", "", "󰄠" })
  elseif option == 7 then
    theme.launch("music", { "󰝚", "󰋍" })
  elseif option == 8 then
    theme.launch("tool", { "󰭪", "󱖦", "", "" })  -- 
  elseif option == 9 then
    theme.launch("settings", { "󰃟", "󰍺", "󱘫" })
  elseif option == 10 then
    msg_now()
  end
end)

awesome.connect_signal("launch::sys", function(option)
  if option == 1 then
    awful.spawn.with_shell("systemctl poweroff")
  elseif option == 2 then
    awful.spawn.with_shell("systemctl reboot")
  elseif option == 3 then
    theme.lock()
    awful.spawn.with_shell("systemctl suspend")
  elseif option == 4 then
    theme.lock()
  elseif option == 5 then
    awesome.quit()
  elseif option == 6 then
    awesome.restart()
  end
end)

awful.keyboard.append_global_keybindings {
  awful.key({ }, "XF86PowerOff", function() theme.launch("sys", { "󰐥", "󰜉", "󰒲", "󰍁", "󰗽", "󱣲" }) end,
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
--  awful.key({ "Mod4", "Shift" }, "minus", function () awful.tag.incgap(-1, nil) end,
--    {description = "decrement gap", group = "tags" }),
--  awful.key({ "Mod4" }, "minus", function () awful.tag.incgap(1, nil) end,
--    {description = "increment gaps", group = "tags" }),
  awful.key({ "Mod4" }, "space", awful.client.urgent.jumpto,
    { description = "jump to urgent client", group = "client" }),

  awful.key({ "Mod4" }, "Return", function() awful.spawn(term()) end,
    { description = "open a terminal", group = "launch" }),
  awful.key({ }, "Menu", function() theme.launch("app", { "", "󰉕", "󰧭", "", "󰘦", "󰖟", "󰽴", "", "", "󱑒" }) end,
    { description = "show the menubar", group = "launch" }),
  awful.key({ }, "Print", function()
    theme.notify({
      title = bold("Screenshot:"),
      message = "select a window or rectangle",
      icon = png("screenshot"),
      timeout = 2
    })
    awful.spawn("slop-shot")
  end,
    { description = "scrot", group = "launch" }),

  awful.key({ }, "XF86Mail", function() awful.spawn.with_shell("xdg-open 'https://mail.google.com'", { switch_to_tags = true }) end,
    { description = "email", group = "launch" }),
  awful.key({ }, "XF86HomePage", function() awful.spawn("qutebrowser") end,
    { description = "browser", group = "launch" }),
  awful.key({ }, "XF86Tools", function() awful.spawn(term("ncmpc")) end,
    { description = "browser", group = "launch" }),
  awful.key({ }, "XF86Launch5", function() awful.spawn(term("nnn")) end,
    { description = "nnn fm", group = "launch" }),
  awful.key({ }, "XF86Launch6", function() awful.spawn("pcmanfm") end,
    { description = "pcmanfm", group = "launch" }),
  awful.key({ }, "XF86Launch9", function() awful.spawn(term("htop")) end,
    { description = "process monitor", group = "launch" }),
  awful.key({ }, "XF86Documents", function() awful.spawn(term("nvim")) end,
    { description = "neovim", group = "launch" }),
  awful.key({ }, "XF86Calculator", function() awful.spawn(term("calc")) end,
    { description = "calc", group = "launch" }),

  awful.key({ }, "XF86AudioLowerVolume", function()
    awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")
    msg_volume("1")
  end,
    { description = "lower", group = "volume" }),
  awful.key({ }, "XF86AudioRaiseVolume", function()
    awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")
    msg_volume("")
 end,
    { description = "raise", group = "volume" }),
  awful.key({ }, "XF86AudioMute", function()
    awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
    msg_muted()
  end,
    { description = "(un)mute", group = "volume" }),

  awful.key({ }, "XF86AudioPlay", function()
    awful.spawn.easy_async_with_shell("mpc toggle", function(out)
      msg_mpd(out, "playerctl_toggle")
    end)
  end,
    { description = "play", group = "music" }),
  awful.key({ }, "XF86AudioPrev", function()
    awful.spawn.easy_async_with_shell("mpc prev", function(out)
      msg_mpd(out, "playerctl_prev")
    end)
  end,
    { description = "previous", group = "music" }),
  awful.key({ }, "XF86AudioNext", function()
    awful.spawn.easy_async_with_shell("mpc next", function(out)
      msg_mpd(out, "playerctl_next")
    end)
  end,
    { description = "next", group = "music" }),
  awful.key({ }, "XF86AudioStop", function()
    awful.spawn("mpc stop")
    msg_mpd_stop("stopped")
  end,
    { description = "stop", group = "music" })
}

-- start
msg_now()
awful.spawn("dex -a")
