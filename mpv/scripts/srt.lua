function srtname(s)
  local patterns = { "%.%w+$", "%b[]", "720p", "1080p", "10Bit", "5%.1", "AAC",
    "AMBER", "BluRay", "BONE", "DDP", "HEVC", "HC", "HDRip", "MeGusta",
    "NeoNoir", "RGB", "TS", "WEB%-DL", "WEBRip", "YIFY", "x264", "x265"
  }

  for _, p in ipairs(patterns) do
    s = string.gsub(s, p, "")
    print(s)
  end
  
  s = string.gsub(s, "[._-]", " ")
  s = string.gsub(s, "%s+", " ")
  return string.match(s, "^%s*(.-)%s*$")
end

if mp ~= nil then
  local function srtadd()
    local name = mp.get_property("filename")
    name = srtname(name);

    mp.command_native_async({
      name = "subprocess",
      capture_stdout = true,
      args = { "srt", name }
    },
    function(success, result, _)
      if success then
        if mp.commandv("sub_add", result.stdout) then
          local sub = string.gsub(result.stdout, "^.*()/", "")
          mp.osd_message("Subtitle " .. sub .. " has been added.", 3)
        end
      end
    end)
  end

 mp.add_key_binding("V", "srt", srtadd)
end
