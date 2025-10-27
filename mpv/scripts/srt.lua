function srtname(s)
  local patterns = { "%.%w+$", "%b[]", "AAC", "BONE", "HEVC", "MeGusta", "WEB%-DL", "WEBRip", "x264", "x265", "720p", "1080p" }

  for _, p in ipairs(patterns) do
    s = string.gsub(s, p, "")
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
