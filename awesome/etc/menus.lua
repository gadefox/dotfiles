local awful = require("awful")
local lock = require("lock")
local menu = require("menu")
local notify = require("notify")
local util = require("util")

local module = {}

function module.browser()
  menu.show("browser", { "󰇩", "󰈹", "󰊯" })
end

function module.file()
  menu.show("file", { "󱗁", "󰖔", "", "", "", "" })
end

function module.main()
  menu.show("main", { "󰊲", "󰉕", "󰧭", "", "󰘦", "󰖟", "󰽴", "", "" })
end

function module.power()
  menu.show("power", { "󰐥", "󰜉", "󰍁", "󰗽", "" })
end

function module.scrot()
  menu.show("scrot", { "", "󰩭", "" })
end

function module.timer()
  menu.show("timer", { "󱑋", "󱑌", "󱑍", "󱑎", "󱑏", "󱑐", "󱑓", "󱑕", "󱫍" })
end

function module.webcam()
  menu.show("webcam", { "", "󱃨", "󱜷", "󱂸" })
end

function module.light()
  awful.spawn.easy_async_with_shell("ddcutil -t getvcp 10 | awk '{print $4}'", function(out)
    local vcp = tonumber(out)
    local idx = vcp < 10 and 1 or
                vcp < 30 and 2 or
                vcp < 50 and 3 or
                vcp < 70 and 4 or
                vcp < 90 and 5 or 6

    menu.show("light", { "󱩍", "󱩐", "󱩑", "󱩓", "󱩕", "󰛨" }, { idx })
  end)
end
function module.setup()
  awesome.connect_signal("menu::file", function(option, mods)
    if option == 1 then
      util.term("nnn")
    elseif option == 2 then
      util.term("mc -x")
    elseif option == 3 then
      awful.spawn("pcmanfm --no-desktop", mods)
    elseif option == 4 then
      awful.spawn("ghex")
    elseif option == 5 then
      awful.spawn("xarchiver")
    elseif option == 6 then
      awful.spawn("evince")
    end
  end)

  awesome.connect_signal("menu::image", function(option, _)
    if option == 1 then
      awful.spawn("gimp")
    elseif option == 2 then
      awful.spawn("gpick")
    elseif option == 3 then
      awful.spawn("xsane")
    end
  end)

  awesome.connect_signal("menu::dev", function(option, _)
    if option == 1 then
      awful.spawn("meld")
    elseif option == 2 then
      awful.spawn("cutecom")
    elseif option == 3 then
      awful.spawn("wireshark")
    elseif option == 4 then
      awful.spawn("arduino")
    elseif option == 5 then
      awful.spawn("ghidra")
    elseif option == 6 then
      awful.spawn("fritzing")
    end
  end)

  awesome.connect_signal("menu::light", function(option, _)
    util.set_ddcutil(option)
    util.set_nvidia(option)
  end)

  awesome.connect_signal("menu::office", function(option, _)
    if option == 1 then
      util.term("nvim")
    elseif option == 2 then
      util.term("calc")
    elseif option == 3 then
      awful.spawn("swriter")
    elseif option == 4 then
      awful.spawn("scalc")
    end
  end)

  awesome.connect_signal("menu::flame", function(option, _)
    if option == 1 then
      awful.spawn("flameshot gui")
    elseif option == 2 then
      awful.spawn("flameshot menuer")
    elseif option == 3 then
      awful.spawn("flameshot config")
    end
  end)

  awesome.connect_signal("menu::scrot", function(option, _)
    if option == 1 then
      awful.spawn("scrot")
    elseif option == 2 then
      awful.spawn("slop-area")
    elseif option == 3 then
      menu.show("flame", { "󰩭", "󰌧", "" })
    end
  end)

  awesome.connect_signal("menu::wifi", function(option, _)
    awful.spawn.with_shell("wifi " .. option)
  end)

  awesome.connect_signal("menu::settings", function(option, _)
    if option == 1 then
      module.light()
    elseif option == 2 then
      awful.spawn("dconf-editor")
    elseif option == 3 then
      awful.spawn("arandr")
    elseif option == 4 then
      awful.spawn("gnome-disks")
    elseif option == 5 then
      menu.show("wifi", { "󰸋", "󱚼", "󱛄", "󱛃", "󱛂", "󱛆" })
    end
  end)

  awesome.connect_signal("menu::webcam", function(option, _)
    if option == 1 then
      awful.spawn("v4l2-flip cheese")
    else
      awful.spawn.with_shell("webcam " .. option)
    end
  end)

  awesome.connect_signal("menu::systray", function(option, _)
    local trayer = "trayer --align right --distance -26 --distancefrom bottom --monitor 1 --widthtype requst"

    if option == 1 then
      awful.spawn(trayer)
    elseif option == 2 then
      awful.spawn("pkill -f '" .. trayer .. "'")
    end
  end)

  awesome.connect_signal("menu::tool", function(option, _)
    if option == 1 then
      module.scrot()
    elseif option == 2 then
      menu.show("systray", { "󱊔", "󱊙" })
    elseif option == 3 then
      module.webcam()
    elseif option == 4 then
      util.term("htop")
    elseif option == 5 then
      util.term("wavemon")
    end
  end)

  awesome.connect_signal("menu::browser", function(option, _)
    if option == 1 then
      awful.spawn("qutebrowser")
    elseif option == 2 then
      awful.spawn("firefox")
    elseif option == 3 then
      awful.spawn("chromium")
    end
  end)

  awesome.connect_signal("menu::web", function(option, _)
    if option == 1 then
      module.browser()
    elseif option == 2 then
      awful.spawn("evolution")
    elseif option == 3 then
      util.term("irssi --home=~/.local/share/irssi")
    elseif option == 4 then
      awful.spawn("transmission-gtk")
    end
  end)

  awesome.connect_signal("menu::music", function(option, _)
    if option == 1 then
      util.term("ncmpc")
    elseif option == 2 then
      util.term("cava")
    elseif option == 3 then
      util.term("pulsemixer")
    elseif option == 4 then
      awful.spawn("aud-dl")
    end
  end)

  awesome.connect_signal("menu::calendar", function(option, _)
    notify.create("calendar", nil, option - 1, 15)
  end)

  awesome.connect_signal("menu::misc", function(option, _)
    if option < 3 then
      awful.spawn("dmenu-run " .. option)
    elseif option == 3 then
      util.term()
    elseif option == 4 then
      menu.show("calendar", { "󰸘", "󱁳" })
    elseif option == 5 then
      awful.spawn("usbsync")
    elseif option == 6 then
      module.timer()
    elseif option == 7 then
      notify.create("clock", "Now:", os.date("%a %d %b, %H:%M"))
    end
  end)

  awesome.connect_signal("menu::timer", function(option, _)
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

  awesome.connect_signal("menu::main", function(option, _)
    if option == 1 then
      menu.show("misc", { "󰌧", "", "", "", "󱤛", "󰔛", "󱑒" })
    elseif option == 2 then
      module.file()
    elseif option == 3 then
      menu.show("office", { "󱩽", "󱖦", "󱎒", "󱎏" })
    elseif option == 4 then
      menu.show("image", { "󱇤", "󰈋", "󰚫" })
    elseif option == 5 then
      menu.show("dev", { "", "󰙜", "", "", "", "" })
    elseif option == 6 then
      menu.show("web", { "󰌀", "", "", "󰄠" })
    elseif option == 7 then
      menu.show("music", { "󰝚", "󰺢", "󰋍", "" })
    elseif option == 8 then
      menu.show("tool", { "󰹑", "󱊖", "󰖠", "", "󱚻" })
    elseif option == 9 then
      awful.spawn.easy_async_with_shell("iwctl station wlan0 show | grep State | awk '{print $2}'", function(out)
        local icon = out == "connected\n" and "󰖩" or
                     out == "disconnected\n" and "󰖪" or "󱚵"

        menu.show("settings", { "󰃟", "", "󰍺", "󱊟", icon })
      end)
    end
  end)

  awesome.connect_signal("menu::awesome", function(option, _)
    if option < 4 then
      awful.spawn("awesome-test " .. option)
    elseif option == 4 then
      awesome.restart()
    end
  end)

  awesome.connect_signal("menu::power", function(option, _)
    if option == 1 then
      awful.spawn("/sbin/poweroff")
    elseif option == 2 then
      awful.spawn("/sbin/reboot")
    elseif option == 3 then
      lock.screen()
    elseif option == 4 then
      awesome.quit()
    elseif option == 5 then
      menu.show("awesome", { "󱇚", "", "󱎠", "󱣲" })
    end
  end)
end

return module
