config.load_autoconfig(False)

c.aliases = {}
c.bindings.key_mappings = {}
c.auto_save.interval = 15000
c.colors.contextmenu.disabled.bg = '#28343A'
c.colors.contextmenu.disabled.fg = '#576267'
c.colors.contextmenu.menu.bg = '#28343A'
c.colors.contextmenu.menu.fg = '#B9C3C8'
c.colors.contextmenu.selected.bg = '#3B484D'
c.colors.contextmenu.selected.fg = '#CFD8DC'
c.colors.completion.category.bg = '#2e3440'
c.colors.completion.category.border.bottom = '#2e3440'
c.colors.completion.category.border.top = '#2e3440'
c.colors.completion.category.fg = '#e5e9f0'
c.colors.completion.even.bg = '#3b4252'
c.colors.completion.odd.bg = '#3b4252'
c.colors.completion.fg = '#d8dee9'
c.colors.completion.item.selected.bg = '#4c566a'
c.colors.completion.item.selected.border.bottom = '#4c566a'
c.colors.completion.item.selected.border.top = '#4c566a'
c.colors.completion.item.selected.fg = '#eceff4'
c.colors.completion.match.fg = '#ebcb8b'
c.colors.completion.scrollbar.bg = '#3b4252'
c.colors.completion.scrollbar.fg = '#e5e9f0'
c.colors.downloads.bar.bg = '#2e3440'
c.colors.downloads.error.bg = '#bf616a'
c.colors.downloads.error.fg = '#e5e9f0'
c.colors.downloads.stop.bg = '#b48ead'
c.colors.downloads.system.bg = 'none'
c.colors.hints.bg = '#ebcb8b'
c.colors.hints.fg = '#2e3440'
c.colors.hints.match.fg = '#5e81ac'
c.colors.keyhint.bg = '#3b4252'
c.colors.keyhint.fg = '#e5e9f0'
c.colors.keyhint.suffix.fg = '#ebcb8b'
c.colors.messages.error.bg = '#bf616a'
c.colors.messages.error.border = '#bf616a'
c.colors.messages.error.fg = '#2e3440'
c.colors.messages.info.bg = '#88c0d0'
c.colors.messages.info.border = '#88c0d0'
c.colors.messages.info.fg = '#2e3440'
c.colors.messages.warning.bg = '#d08770'
c.colors.messages.warning.border = '#d08770'
c.colors.messages.warning.fg = '#e5e9f0'
c.colors.prompts.bg = '#434c5e'
c.colors.prompts.border = '1px solid ' + '#2e3440'
c.colors.prompts.fg = '#e5e9f0'
c.colors.prompts.selected.bg = '#4c566a'
c.colors.statusbar.caret.bg = '#b48ead'
c.colors.statusbar.caret.fg = '#e5e9f0'
c.colors.statusbar.caret.selection.bg = '#b48ead'
c.colors.statusbar.caret.selection.fg = '#e5e9f0'
c.colors.statusbar.command.bg = '#434c5e'
c.colors.statusbar.command.fg = '#e5e9f0'
c.colors.statusbar.command.private.bg = '#434c5e'
c.colors.statusbar.command.private.fg = '#e5e9f0'
c.colors.statusbar.insert.bg = '#a3be8c'
c.colors.statusbar.insert.fg = '#2e3440'
c.colors.statusbar.normal.bg = '#2e3440'
c.colors.statusbar.normal.fg = '#e5e9f0'
c.colors.statusbar.passthrough.bg = '#5e81ac'
c.colors.statusbar.passthrough.fg = '#e5e9f0'
c.colors.statusbar.private.bg = '#4c566a'
c.colors.statusbar.private.fg = '#e5e9f0'
c.colors.statusbar.progress.bg = '#e5e9f0'
c.colors.statusbar.url.error.fg = '#bf616a'
c.colors.statusbar.url.fg = '#e5e9f0'
c.colors.statusbar.url.hover.fg = '#88c0d0'
c.colors.statusbar.url.success.http.fg = '#e5e9f0'
c.colors.statusbar.url.success.https.fg = '#a3be8c'
c.colors.statusbar.url.warn.fg = '#d08770'
c.colors.tabs.bar.bg = '#4c566a'
c.colors.tabs.even.bg = '#4c566a'
c.colors.tabs.even.fg = '#e5e9f0'
c.colors.tabs.indicator.error = '#bf616a'
c.colors.tabs.indicator.system = 'none'
c.colors.tabs.odd.bg = '#4c566a'
c.colors.tabs.odd.fg = '#e5e9f0'
c.colors.tabs.selected.even.bg = '#2e3440'
c.colors.tabs.selected.even.fg = '#e5e9f0'
c.colors.tabs.selected.odd.bg = '#2e3440'
c.colors.tabs.selected.odd.fg = '#e5e9f0'
c.colors.tooltip.bg = '#1E282D'
c.colors.tooltip.fg = '#B9C3C8'
c.content.autoplay = False
c.content.desktop_capture = False
c.content.geolocation = False
c.content.media.audio_capture = False
c.content.media.audio_video_capture = False
c.content.media.video_capture = False
c.content.mouse_lock = False
c.content.notifications.enabled = True
c.content.notifications.presenter = 'libnotify'
c.content.persistent_storage = False
c.content.register_protocol_handler = True
c.content.site_specific_quirks.skip = []
c.content.pdfjs = True
c.downloads.prevent_mixed_content = False
c.editor.command = ['st', '-e', 'nvim', '{file}']
c.fileselect.single_file.command = ['st', '-e', 'nnn', '{}']
c.fileselect.multiple_files.command = ['st', '-e', 'nnn', '{}']
c.fileselect.folder.command = ['st', '-e', 'nnn', '{}']
c.fonts.default_size = '11pt'
c.fonts.tooltip = '12pt'
c.hints.chars = 'aszx'
c.messages.timeout = 5000
c.spellcheck.languages = ['en-US']
c.statusbar.show = 'in-mode'
c.statusbar.padding = {'bottom': 1, 'left': 0, 'right': 0, 'top': 1}
c.statusbar.widgets = ['keypress', 'url', 'scroll', 'history', 'progress']
c.tabs.background = False
c.tabs.close_mouse_button = 'right'
c.tabs.close_mouse_button_on_bar = 'close-current'
c.tabs.favicons.show = 'pinned'
c.tabs.last_close = 'close'
c.tabs.title.format = '{current_title}'
c.url.default_page = 'https://www.google.com'
c.url.start_pages = 'https://www.google.com'
c.window.title_format = '_'
c.zoom.default = '130%'
c.zoom.levels = ["100%", "110%", "120%", "130%", "140%", "150%"]

c.url.searchengines = {
  'DEFAULT': 'https://www.google.com/search?q={}',
  'r': 'https://reddit.com/r/{}',
  's': 'https://stackoverflow.com/search?q={}',
  'w': 'https://en.wikipedia.org/wiki/{}',
  'y': 'https://www.youtube.com/results?search_query={}'
}

c.bindings.default['normal'] = {
  'Escape': 'fullscreen --leave',
  '<Ctrl+Backspace>': 'back',
  '<Ctrl+Del>': 'tab-close',
  '<Ctrl+PgDown>': 'tab-prev',
  '<Ctrl+PgUp>': 'tab-next',
  '<Ctrl+b>': 'config-cycle content.blocking.enabled true false',
  '<F5>': 'reload',
  '<Ins>': 'mode-enter insert',
  '[': 'cmd-set-text -s :open',
  ']': 'cmd-set-text -s :open -t',
  '/': 'cmd-set-text /',
  '?': 'cmd-set-text ?',
  ':': 'cmd-set-text :',
  '\\a': 'hint links spawn yt-mp3 {hint-url}',
  '\\p': 'hint links spawn mpv {hint-url}',
  '\\v': 'hint links spawn yt-mp4 {hint-url}',
  'b': 'bookmark-add',
  'B': 'quickmark-save',
  'cd': 'download-clear',
  'ch': 'history-clear',
  'cm': 'clear-messages',
  'da': 'spawn yt-mp3 {url}',
  'n': 'search-next',
  'N': 'search-prev',
  'y': 'yank',
  'p': 'spawn mpv {url}',
}

c.bindings.default['hint'] = {
  '<Escape>': 'mode-leave',
  '<Return>': 'hint-follow'
}

c.bindings.default['command'] = {
  '<Escape>': 'mode-leave',
  '<Return>': 'command-accept',
  '<Up>': 'completion-item-focus --history prev',
  '<Down>': 'completion-item-focus --history next',
  '<Shift+Tab>': 'completion-item-focus prev',
  '<Tab>': 'completion-item-focus next',
  '<Ctrl+Tab>': 'completion-item-focus next-category',
  '<Ctrl+Shift+Tab>': 'completion-item-focus prev-category',
  '<PgDown>': 'completion-item-focus next-page',
  '<PgUp>': 'completion-item-focus prev-page',
  '<Ctrl+Del>': 'completion-item-del',
  '<Ctrl+c>': 'completion-item-yank'
}

c.bindings.default['prompt'] = {
  '<Escape>': 'mode-leave',
  '<Return>': 'prompt-accept',
  '<Up>': 'prompt-item-focus prev',
  '<Down>': 'prompt-item-focus next',
  '<Ctrl-y>': 'prompt-yank',
  '<Ctrl-o>': 'prompt-open-download',
  '<Ctrl-p>': 'prompt-open-download --pdfjs'
}

c.bindings.default['insert'] = {
  '<Escape>': 'mode-leave',
  '<Ins>': 'mode-leave',
  '<Shift-Escape>': 'fake-key <Escape>',
  '<Ctrl-e>': 'edit-text'
}
