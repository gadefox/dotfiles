local function srt()
  local name = mp.get_property("filename")
  name = string.gsub(name, "%.%w+$", "")

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

mp.add_key_binding("b", "srt", srt)
