term = "kitty"
config.load_autoconfig(False)
config.set("content.autoplay", True, "*://*.imdb.com/*")

c.aliases = {}
c.bindings.key_mappings = {}
c.auto_save.interval = 15000
c.colors.contextmenu.disabled.bg = "#28343A"
c.colors.contextmenu.disabled.fg = "#576267"
c.colors.contextmenu.menu.bg = "#28343A"
c.colors.contextmenu.menu.fg = "#B9C3C8"
c.colors.contextmenu.selected.bg = "#3B484D"
c.colors.contextmenu.selected.fg = "#CFD8DC"
c.colors.completion.category.bg = "#2E3440"
c.colors.completion.category.border.bottom = "#2E3440"
c.colors.completion.category.border.top = "#2E3440"
c.colors.completion.category.fg = "#E5E9F0"
c.colors.completion.even.bg = "#3B4252"
c.colors.completion.odd.bg = "#3B4252"
c.colors.completion.fg = "#D8DEE9"
c.colors.completion.item.selected.bg = "#4C566A"
c.colors.completion.item.selected.border.bottom = "#4C566A"
c.colors.completion.item.selected.border.top = "#4C566A"
c.colors.completion.item.selected.fg = "#ECEFF4"
c.colors.completion.match.fg = "#EBCB8B"
c.colors.completion.scrollbar.bg = "#3B4252"
c.colors.completion.scrollbar.fg = "#E5E9F0"
c.colors.downloads.bar.bg = "#2E3440"
c.colors.downloads.error.bg = "#BF616A"
c.colors.downloads.error.fg = "#E5E9F0"
c.colors.downloads.stop.bg = "#B48EAD"
c.colors.downloads.system.bg = "none"
c.colors.hints.bg = "#EBCB8B"
c.colors.hints.fg = "#2E3440"
c.colors.hints.match.fg = "#5E81AC"
c.colors.keyhint.bg = "#3B4252"
c.colors.keyhint.fg = "#E5E9F0"
c.colors.keyhint.suffix.fg = "#EBCB8B"
c.colors.messages.error.bg = "#BF616A"
c.colors.messages.error.border = "#BF616A"
c.colors.messages.error.fg = "#2E3440"
c.colors.messages.info.bg = "#88C0D0"
c.colors.messages.info.border = "#88C0D0"
c.colors.messages.info.fg = "#2E3440"
c.colors.messages.warning.bg = "#D08770"
c.colors.messages.warning.border = "#D08770"
c.colors.messages.warning.fg = "#E5E9F0"
c.colors.prompts.bg = "#434C5E"
c.colors.prompts.border = "1px solid " + "#2E3440"
c.colors.prompts.fg = "#E5E9F0"
c.colors.prompts.selected.bg = "#4C566A"
c.colors.statusbar.caret.bg = "#B48EAD"
c.colors.statusbar.caret.fg = "#E5E9F0"
c.colors.statusbar.caret.selection.bg = "#B48EAD"
c.colors.statusbar.caret.selection.fg = "#E5E9F0"
c.colors.statusbar.command.bg = "#434C5E"
c.colors.statusbar.command.fg = "#E5E9F0"
c.colors.statusbar.command.private.bg = "#434C5E"
c.colors.statusbar.command.private.fg = "#E5E9F0"
c.colors.statusbar.insert.bg = "#A3BE8C"
c.colors.statusbar.insert.fg = "#2E3440"
c.colors.statusbar.normal.bg = "#2E3440"
c.colors.statusbar.normal.fg = "#E5E9F0"
c.colors.statusbar.passthrough.bg = "#5E81AC"
c.colors.statusbar.passthrough.fg = "#E5E9F0"
c.colors.statusbar.private.bg = "#4C566A"
c.colors.statusbar.private.fg = "#E5E9F0"
c.colors.statusbar.progress.bg = "#E5E9F0"
c.colors.statusbar.url.error.fg = "#BF616A"
c.colors.statusbar.url.fg = "#E5E9F0"
c.colors.statusbar.url.hover.fg = "#88C0D0"
c.colors.statusbar.url.success.http.fg = "#E5E9F0"
c.colors.statusbar.url.success.https.fg = "#A3BE8C"
c.colors.statusbar.url.warn.fg = "#D08770"
c.colors.tabs.bar.bg = "#4C566A"
c.colors.tabs.even.bg = "#4C566A"
c.colors.tabs.even.fg = "#E5E9F0"
c.colors.tabs.indicator.error = "#BF616A"
c.colors.tabs.indicator.system = "none"
c.colors.tabs.odd.bg = "#4C566A"
c.colors.tabs.odd.fg = "#E5E9F0"
c.colors.tabs.selected.even.bg = "#2E3440"
c.colors.tabs.selected.even.fg = "#E5E9F0"
c.colors.tabs.selected.odd.bg = "#2E3440"
c.colors.tabs.selected.odd.fg = "#E5E9F0"
c.colors.tooltip.bg = "#1E282D"
c.colors.tooltip.fg = "#B9C3C8"
c.content.autoplay = False
c.content.desktop_capture = False
c.content.geolocation = False
c.content.javascript.clipboard = "access"
c.content.media.audio_capture = False
c.content.media.audio_video_capture = False
c.content.media.video_capture = False
c.content.mouse_lock = False
c.content.notifications.enabled = True
c.content.notifications.presenter = "libnotify"
c.content.persistent_storage = False
c.content.register_protocol_handler = True
c.content.site_specific_quirks.skip = []
c.content.pdfjs = True
c.downloads.prevent_mixed_content = False
c.editor.command = [term, "-e", "nvim", "{file}"]
c.fileselect.single_file.command = [term, "-e", "nnn", "{}"]
c.fileselect.multiple_files.command = [term, "-e", "nnn", "{}"]
c.fileselect.folder.command = [term, "-e", "nnn", "{}"]
c.fonts.default_size = "11pt"
c.fonts.tooltip = "12pt"
c.hints.chars = "aszx"
c.messages.timeout = 5000
c.spellcheck.languages = ["en-US"]
c.statusbar.show = "in-mode"
c.statusbar.padding = {"bottom": 1, "left": 0, "right": 0, "top": 1}
c.statusbar.widgets = ["keypress", "url", "scroll", "history", "progress"]
c.tabs.background = False
c.tabs.close_mouse_button = "right"
c.tabs.close_mouse_button_on_bar = "close-current"
c.tabs.favicons.show = "pinned"
c.tabs.last_close = "close"
c.tabs.title.format = "{current_title}"
c.url.default_page = "https://www.google.com"
c.url.start_pages = "https://www.google.com"
c.window.title_format = "_"
c.zoom.default = "130%"
c.zoom.levels = ["100%", "110%", "120%", "130%", "140%", "150%"]

c.url.searchengines = {
  "DEFAULT": "https://www.google.com/search?hl=en&q={}",
  "i": "https://www.imdb.com/find?q={}",
  "m": "https://www.google.com/maps/search/{}",
  "r": "https://reddit.com/search?q={}",
  "w": "https://en.wikipedia.org/wiki/{}",
  "y": "https://www.youtube.com/results?search_query={}"
}

c.bindings.default["command"] = {
  "<Escape>": "mode-leave",
  "<Return>": "command-accept",
  "<Up>": "completion-item-focus --history prev",
  "<Down>": "completion-item-focus --history next",
  "<Shift+Tab>": "completion-item-focus prev",
  "<Tab>": "completion-item-focus next",
  "<Ctrl+Tab>": "completion-item-focus next-category",
  "<Ctrl+Shift+Tab>": "completion-item-focus prev-category",
  "<PgDown>": "completion-item-focus next-page",
  "<PgUp>": "completion-item-focus prev-page",
  "<Ctrl+Del>": "completion-item-del",
  "<Ctrl+c>": "completion-item-yank"
}

c.bindings.default["hint"] = {
  "<Escape>": "mode-leave",
  "<Return>": "hint-follow"
}

c.bindings.default["insert"] = {
  "<Escape>": "mode-leave",
  "<Ins>": "mode-leave",
  "<Shift-Escape>": "fake-key <Escape>",
  "<Ctrl-e>": "edit-text"
}

c.bindings.default["normal"] = {
  "Escape": "fullscreen --leave",
  "<Ctrl+Backspace>": "back",
  "<Ctrl+Del>": "tab-close",
  "<Ctrl+PgDown>": "tab-prev",
  "<Ctrl+PgUp>": "tab-next",
  "<Ctrl+b>": "config-cycle content.blocking.enabled true false",
  "<F5>": "reload",
  "<Ins>": "mode-enter insert",
  "[": "cmd-set-text -s :open",
  "]": "cmd-set-text -s :open -t",
  "/": "cmd-set-text /",
  "?": "cmd-set-text ?",
  ":": "cmd-set-text :",
  "\\a": "hint links spawn yt-mp3 {hint-url}",
  "\\p": "hint links spawn mpv {hint-url}",
  "\\v": "hint links spawn yt-mp4 {hint-url}",
  "b": "bookmark-add",
  "B": "quickmark-save",
  "cd": "download-clear",
  "ch": "history-clear",
  "cm": "clear-messages",
  "da": "spawn yt-mp3 {url}",
  "n": "search-next",
  "N": "search-prev",
  "y": "yank",
  "p": "spawn mpv {url}",
}

c.bindings.default["prompt"] = {
  "<Escape>": "mode-leave",
  "<Return>": "prompt-accept",
  "<Up>": "prompt-item-focus prev",
  "<Down>": "prompt-item-focus next",
  "<Ctrl-y>": "prompt-yank",
  "<Ctrl-o>": "prompt-open-download",
  "<Ctrl-p>": "prompt-open-download --pdfjs"
}
