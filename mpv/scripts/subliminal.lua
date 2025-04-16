local utils = require("mp.utils")

function subliminal()
  mp.osd_message("Searching subtitle..")

  local path = mp.get_property("path")
  local exec = {
    args = {
      "subliminal", "download", "--single", "--force", "--language=en",
      path
    }
  }

  local res = utils.subprocess(exec)
  if res.error == nil then
    local srt = string.gsub(path, "%.%w+$", ".srt")
    if mp.commandv("sub_add", srt) then
      mp.osd_message("Subtitle download succeeded.")
    end
  end
end

mp.add_key_binding("b", "subliminal", subliminal)
