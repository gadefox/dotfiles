function name()
  local name = mp.get_property("filename")
  
  name = string.gsub(name, "%.%w+$", "")
  name = string.gsub(name, "%-%[YTS%.MX%]$", "")
  name = string.gsub(name, "%.AAC", "")
  name = string.gsub(name, "%.x264", "")
  name = string.gsub(name, "%.WEBRip", "")
  name = string.gsub(name, "%.720p", "")
  name = string.gsub(name, "[._]", " ")

  return name
end

local function srt()
  mp.command_native_async({
    name = "subprocess",
    capture_stdout = true,
    args = { "srt", name() }
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

mp.add_key_binding("V", "srt", srt)
