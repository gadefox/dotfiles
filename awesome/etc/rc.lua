require("awful.autofocus")

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

-- notifications
local notify_kblayout, notify_volume, notify_music
local widget_kblayout = awful.widget.keyboardlayout()

widget_kblayout:connect_signal("widget::redraw_needed", function ()
  notify_kblayout = theme.show_notify(notify_kblayout, "keyboard", "Keyboard layout:", widget_kblayout.widget.text)
end)

local function msg_volume(icon)
  awful.spawn.easy_async_with_shell("pactl list sinks | grep '^[[:space:]]Volume:' | awk '{print $5}'", function(out)
    notify_volume = theme.show_notify(notify_volume, icon, "Volume:", string.gsub(out, "\n", ""))
  end)
end

local function msg_muted()
  awful.spawn.easy_async_with_shell("pactl list sinks | grep 'Mute:' | awk '{print $2}'", function(out)
    notify_volume = out == "no\n"
      and theme.show_notify(notify_volume, "volume", "Volume:", "unmuted")
      or theme.show_notify(notify_volume, "muted", "Volume:", "muted")
  end)
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

    notify_music = theme.show_notify(notify_music, icon, artist, song)
  else
    notify_music = theme.show_notify(notify_music, "toggle", "Music player:", status == "paused" and status or "stopped")
  end
end

-- key bindings
local function term(cmd)
  local ret = "kitty -1"
  if cmd then
    ret = ret .. " -e " .. cmd
  end
  return ret
end

local function spawn(cmd, mods)
  if mods.ctrl then
    awful.spawn(cmd)
  end
  awful.spawn(cmd)
end

awesome.connect_signal("launch::file", function(option, mods)
  if option == 1 then
    spawn(term("nnn"), mods)
  elseif option == 2 then
    spawn(term("mc"), mods)
  elseif option == 3 then
    spawn("pcmanfm", mods)
  elseif option == 4 then
    awful.spawn("xarchiver")
  elseif option == 5 then
    awful.spawn("evince")
  end
end)

awesome.connect_signal("launch::image", function(option, _)
  if option == 1 then
    awful.spawn("gimp")
  elseif option == 2 then
    awful.spawn("gpick")
  elseif option == 3 then
    awful.spawn("xsane")
  end
end)

awesome.connect_signal("launch::dev", function(option, _)
  if option == 1 then
    awful.spawn("wireshark")
  elseif option == 2 then
    awful.spawn("cutecom")
  elseif option == 3 then
    awful.spawn("meld")
  elseif option == 4 then
    awful.spawn("arduino")
  elseif option == 5 then
    awful.spawn("ghidra")
  elseif option == 6 then
    awful.spawn("fritzing")
  end
end)

awesome.connect_signal("launch::light", function(option, _)
  local bright0, contrast0, bright1, contrast1

  if option == 1 then
    bright0 = -1
    contrast0 = -1
    bright1 = 0
    contrast1 = 0
  elseif option == 2 then
    bright0 = -0.6
    contrast0 = -0.6
    bright1 = 20
    contrast1 = 20
  elseif option == 3 then
    bright0 = -0.2
    contrast0 = -0.2
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

  awful.spawn.easy_async("ddcutil setvcp 10 " .. bright1, function()
    awful.spawn("ddcutil setvcp 12 " .. contrast1)
  end)

  local cmd = "nvidia-settings"
  local rgb_names = { "Red", "Green", "Blue" }
  for _, color in ipairs(rgb_names) do
    cmd = cmd .. " -a [DPY:LVDS-0]/" .. color .. "Brightness=" .. bright0
    cmd = cmd .. " -a [DPY:LVDS-0]/" .. color .. "Contrast=" .. contrast0
  end
  awful.spawn(cmd)
end)

awesome.connect_signal("launch::office", function(option, _)
  if option == 1 then
    awful.spawn(term("nvim"))
  elseif option == 2 then
    awful.spawn(term("calc"))
  elseif option == 3 then
    awful.spawn("swriter")
  elseif option == 4 then
    awful.spawn("scalc")
  end
end)

awesome.connect_signal("launch::flame", function(option, _)
  if option == 1 then
    awful.spawn("flameshot gui")
  elseif option == 2 then
    awful.spawn("flameshot launcher")
  elseif option == 3 then
    awful.spawn("flameshot config")
  end
end)

awesome.connect_signal("launch::scrot", function(option, _)
  if option == 1 then
    awful.spawn("scrot")
  elseif option == 2 then
    awful.spawn("slop-area")
  elseif option == 3 then
    theme.launch("flame", { "󰩭", "󰌧", "" })
  end
end)

awesome.connect_signal("launch::wifi", function(option, _)
  awful.spawn.with_shell("wifi " .. option)
end)

awesome.connect_signal("launch::settings", function(option, _)
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
    awful.spawn("dconf-editor")
  elseif option == 3 then
    awful.spawn("arandr")
  elseif option == 4 then
    awful.spawn("gnome-disks")
  elseif option == 5 then
    theme.launch("wifi", { "󰸋", "󱚼", "󱛄", "󱛃", "󱛂", "󱛆" })
  end
end)

awesome.connect_signal("launch::webcam", function(option, _)
  if option == 1 then
    awful.spawn("v4l2-flip cheese")
  else
    awful.spawn.with_shell("webcam " .. option)
  end
end)

local function launch_scrot()
  theme.launch("scrot", { "", "󰩭", "" })
end

awesome.connect_signal("launch::systray", function(option, _)
  local trayer = "trayer --align right --distance -26 --distancefrom bottom --monitor 1 --widthtype requst"

  if option == 1 then
    awful.spawn(trayer)
  elseif option == 2 then
    awful.spawn("pkill -f '" .. trayer .. "'")
  end
end)

local function launch_webcam()
  theme.launch("webcam", { "", "󱃨", "󱜷", "󱂸" })
end

awesome.connect_signal("launch::tool", function(option, _)
  if option == 1 then
    launch_scrot()
  elseif option == 2 then
    theme.launch("systray", { "󱊔", "󱊙" })
  elseif option == 3 then
    launch_webcam()
  elseif option == 4 then
    awful.spawn(term("htop"))
  elseif option == 5 then
    awful.spawn(term("wavemon"))
  end
end)

awesome.connect_signal("launch::browser", function(option, _)
  if option == 1 then
    awful.spawn("qutebrowser")
  elseif option == 2 then
    awful.spawn("firefox")
  elseif option == 3 then
    awful.spawn("chromium")
  end
end)

local function launch_browser()
  theme.launch("browser", { "󰇩", "󰈹", "󰊯" })
end

awesome.connect_signal("launch::web", function(option, _)
  if option == 1 then
    launch_browser()
  elseif option == 2 then
    awful.spawn("evolution")
  elseif option == 3 then
    awful.spawn(term("irssi --home=~/.local/share/irssi"))
  elseif option == 4 then
    awful.spawn("transmission-gtk")
  end
end)

awesome.connect_signal("launch::music", function(option, _)
  if option == 1 then
    awful.spawn(term("ncmpc"))
  elseif option == 2 then
    awful.spawn(term("cava"))
  elseif option == 3 then
    awful.spawn(term("pulsemixer"))
  elseif option == 4 then
    awful.spawn("aud-dl")
  end
end)

awesome.connect_signal("launch::calendar", function(option, _)
  theme.create_notify("calendar", nil, option - 1, 15)
end)

local function launch_timer()
  theme.launch("timer", { "󱑋", "󱑌", "󱑍", "󱑎", "󱑏", "󱑐", "󱑓", "󱑕", "󱫍" })
end

awesome.connect_signal("launch::misc", function(option, _)
  if option == 1 then
    awful.spawn(term())
  elseif option < 4 then
    awful.spawn("dmenu-run " .. option - 1)
  elseif option == 4 then
    theme.launch("calendar", { "󰸘", "󱁳" })
  elseif option == 5 then
    awful.spawn("usbsync")
  elseif option == 6 then
    launch_timer()
  elseif option == 7 then
    theme.create_notify("alarm", "Now:", os.date("%a %d %b, %H:%M"))
  end
end)

awesome.connect_signal("launch::timer", function(option, _)
  if option == 1 then
    awful.spawn("timer 5")
  elseif option == 2 then
    awful.spawn("timer 10")
  elseif option == 3 then
    awful.spawn("timer 15")
  elseif option == 4 then
    awful.spawn("timer 20")
  elseif option == 5 then
    awful.spawn("timer 25")
  elseif option == 6 then
    awful.spawn("timer 30")
elseif option == 7 then
    awful.spawn("timer 45")
  elseif option == 8 then
    awful.spawn("timer 55")
  elseif option == 9 then
    awful.spawn("timer")
  end
end)

local function launch_file()
  theme.launch("file", { "󱗁", "󰖔", "", "", "" })
end

awesome.connect_signal("launch::menu", function(option, _)
  if option == 1 then
    theme.launch("misc", { "", "󰌧", "", "", "󱤛", "󰔛", "󱑒" })
  elseif option == 2 then
    launch_file()
  elseif option == 3 then
    theme.launch("office", { "󱩽", "󱖦", "󱎒", "󱎏" })
  elseif option == 4 then
    theme.launch("image", { "󱇤", "󰈋", "󰚫" })
  elseif option == 5 then
    theme.launch("dev", { "", "󰙜", "", "", "", "" })
  elseif option == 6 then
    theme.launch("web", { "󰌀", "", "", "󰄠" })
  elseif option == 7 then
    theme.launch("music", { "󰝚", "󰺢", "󰋍", "" })
  elseif option == 8 then
    theme.launch("tool", { "󰹑", "󱊖", "󰖠", "", "󱚻" })
  elseif option == 9 then
    awful.spawn.easy_async_with_shell("iwctl station wlan0 show | grep State | awk '{print $2}'", function(out)
      local wifi = out == "connected\n" and "󰖩" or
                   out == "disconnected\n" and "󰖪" or "󱚵"

      theme.launch("settings", { "󰃟", "", "󰍺", "󱊟", wifi })
    end)
  end
end)

awesome.connect_signal("launch::power", function(option, _)
  if option == 1 then
    awful.spawn("/sbin/poweroff")
  elseif option == 2 then
    awful.spawn("/sbin/reboot")
  elseif option == 3 then
    theme.lock()
  elseif option == 4 then
    awesome.quit()
  elseif option == 5 then
    awesome.restart()
  end
end)

awful.keyboard.append_global_keybindings({
  awful.key({ }, "XF86PowerOff", theme.launch_power,
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
  awful.key({ "Mod4" }, "space", awful.client.urgent.jumpto,
    { description = "jump to urgent client", group = "client" }),
  awful.key({ "Mod4" }, "Return", function() awful.spawn(term()) end,
    { description = "open a terminal", group = "launch" }),
  awful.key({ }, "Menu", theme.launch_menu,
    { description = "show menubar", group = "launch" }),
  awful.key({ }, "Print", launch_scrot,
    { description = "printscreen", group = "launch" }),
  awful.key({ }, "XF86Mail", function() awful.spawn("evolution") end,
    { description = "email", group = "launch" }),
  awful.key({ }, "XF86HomePage", launch_browser,
    { description = "browser", group = "launch" }),
  awful.key({ }, "XF86Messenger", function() awful.spawn(term("irssi --home=~/.local/share/irssi")) end,
    { description = "messenger", group = "launch" }),
  awful.key({ }, "XF86Tools", function() awful.spawn(term("ncmpc")) end,
    { description = "browser", group = "launch" }),
  awful.key({ }, "XF86Launch5", function() launch_file() end,
    { description = "files", group = "launch" }),
  awful.key({ }, "XF86Launch8", function() launch_webcam() end,
    { description = "camera", group = "launch" }),
  awful.key({ }, "XF86Launch9", function() awful.spawn(term("htop")) end,
    { description = "process monitor", group = "launch" }),
  awful.key({ }, "XF86Favorites", launch_timer,
    { description = "timer", group = "launch" }),
  awful.key({ }, "XF86Documents", function() awful.spawn(term("nvim")) end,
    { description = "neovim", group = "launch" }),
  awful.key({ }, "XF86Calculator", function() awful.spawn(term("calc")) end,
    { description = "calc", group = "launch" }),
  awful.key({ }, "XF86AudioLowerVolume", function()
    awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")
    msg_volume("volume1")
  end,
    { description = "lower", group = "volume" }),
  awful.key({ }, "XF86AudioRaiseVolume", function()
    awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")
    msg_volume("volume")
 end,
    { description = "raise", group = "volume" }),
  awful.key({ }, "XF86AudioMute", function()
    awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
    msg_muted()
  end,
    { description = "(un)mute", group = "volume" }),
  awful.key({ }, "XF86AudioPlay", function()
    awful.spawn.easy_async("mpc toggle", function(out)
      msg_mpd(out, "music")
    end)
  end,
    { description = "play", group = "music" }),
  awful.key({ }, "XF86AudioPrev", function()
    awful.spawn.easy_async("mpc prev", function(out)
      msg_mpd(out, "prev")
    end)
  end,
    { description = "previous", group = "music" }),
  awful.key({ }, "XF86AudioNext", function()
    awful.spawn.easy_async("mpc next", function(out)
      msg_mpd(out, "next")
    end)
  end,
    { description = "next", group = "music" }),
  awful.key({ }, "XF86AudioStop", function()
    awful.spawn("mpc stop")
    notify_music = theme.show_notify(notify_music, "toggle", "Music player:", "stopped")
  end,
    { description = "stop", group = "music" })
})

-- start
awful.spawn("dex -a")
theme.create_notify("calendar", nil, 0, 15)
