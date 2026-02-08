local module = {}

function module.get_name(s)
  local patterns = { "%.%w+$", "%b[]", "720p", "1080p", "10Bit", "5%.1", "AAC",
    "AMBER", "AMZN", "BluRay", "BONE", "DDP", "GalaxyTV", "HEVC", "HC", "HDRip",
    "ION10", "MeGusta", "NeoNoir", "RGB", "TS", "WEB%-DL", "WEBRip", "YIFY",
    "x264", "x265" }

  for _, p in ipairs(patterns) do
    s = string.gsub(s, p, "")
  end
  
  s = string.gsub(s, "[._-]", " ")
  s = string.gsub(s, "%s+", " ")
  return string.match(s, "^%s*(.-)%s*$")
end

local function sub_dnld()
  local name = mp.get_property("filename")
  name = module.get_name(name)

  mp.command_native_async({
    name = "subprocess",
    capture_stdout = true,
    args = { "srt", name }
  },
  function(success, result, _)
    if success and mp.commandv("sub_add", result.stdout) then
      local sub = string.gsub(result.stdout, "^.*()/", "")
      mp.osd_message("Subtitle " .. sub .. " has been added.", 3)
    end
  end)
end

if mp then
  mp.add_key_binding("v", "sub_dnld", sub_dnld)
else
  return module
end
