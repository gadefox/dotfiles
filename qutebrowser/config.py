config.load_autoconfig(False)

nord0 = '#2e3440'
nord1 = '#3b4252'
nord2 = '#434c5e'
nord3 = '#4c566a'
nord4 = '#d8dee9'
nord5 = '#e5e9f0'
nord6 = '#eceff4'
nord7 = '#88c0d0'
nord8 = '#5e81ac'
nord9 = '#bf616a'
nord10 = '#d08770'
nord11 = '#ebcb8b'
nord12 = '#a3be8c'
nord13 = '#b48ead'

c.aliases = {}
c.bindings.key_mappings = {}
c.auto_save.interval = 15000
c.colors.completion.category.bg = nord0
c.colors.completion.category.border.bottom = nord0
c.colors.completion.category.border.top = nord0
c.colors.completion.category.fg = nord5
c.colors.completion.even.bg = nord1
c.colors.completion.odd.bg = nord1
c.colors.completion.fg = nord4
c.colors.completion.item.selected.bg = nord3
c.colors.completion.item.selected.border.bottom = nord3
c.colors.completion.item.selected.border.top = nord3
c.colors.completion.item.selected.fg = nord6
c.colors.completion.match.fg = nord11
c.colors.completion.scrollbar.bg = nord1
c.colors.completion.scrollbar.fg = nord5
c.colors.downloads.bar.bg = nord0
c.colors.downloads.error.bg = nord9
c.colors.downloads.error.fg = nord5
c.colors.downloads.stop.bg = nord13
c.colors.downloads.system.bg = 'none'
c.colors.hints.bg = nord11
c.colors.hints.fg = nord0
c.colors.hints.match.fg = nord8
c.colors.keyhint.bg = nord1
c.colors.keyhint.fg = nord5
c.colors.keyhint.suffix.fg = nord11
c.colors.messages.error.bg = nord9
c.colors.messages.error.border = nord9
c.colors.messages.error.fg = nord5
c.colors.messages.info.bg = nord7
c.colors.messages.info.border = nord7
c.colors.messages.info.fg = nord0
c.colors.messages.warning.bg = nord10
c.colors.messages.warning.border = nord10
c.colors.messages.warning.fg = nord5
c.colors.prompts.bg = nord2
c.colors.prompts.border = '1px solid ' + nord0
c.colors.prompts.fg = nord5
c.colors.prompts.selected.bg = nord3
c.colors.statusbar.caret.bg = nord13
c.colors.statusbar.caret.fg = nord5
c.colors.statusbar.caret.selection.bg = nord13
c.colors.statusbar.caret.selection.fg = nord5
c.colors.statusbar.command.bg = nord2
c.colors.statusbar.command.fg = nord5
c.colors.statusbar.command.private.bg = nord2
c.colors.statusbar.command.private.fg = nord5
c.colors.statusbar.insert.bg = nord12
c.colors.statusbar.insert.fg = nord0
c.colors.statusbar.normal.bg = nord0
c.colors.statusbar.normal.fg = nord5
c.colors.statusbar.passthrough.bg = nord8
c.colors.statusbar.passthrough.fg = nord5
c.colors.statusbar.private.bg = nord3
c.colors.statusbar.private.fg = nord5
c.colors.statusbar.progress.bg = nord5
c.colors.statusbar.url.error.fg = nord9
c.colors.statusbar.url.fg = nord5
c.colors.statusbar.url.hover.fg = nord7
c.colors.statusbar.url.success.http.fg = nord5
c.colors.statusbar.url.success.https.fg = nord12
c.colors.statusbar.url.warn.fg = nord10
c.colors.tabs.bar.bg = nord3
c.colors.tabs.even.bg = nord3
c.colors.tabs.even.fg = nord5
c.colors.tabs.indicator.error = nord9
c.colors.tabs.indicator.system = 'none'
c.colors.tabs.odd.bg = nord3
c.colors.tabs.odd.fg = nord5
c.colors.tabs.selected.even.bg = nord0
c.colors.tabs.selected.even.fg = nord5
c.colors.tabs.selected.odd.bg = nord0
c.colors.tabs.selected.odd.fg = nord5
c.content.site_specific_quirks.skip = []
c.content.blocking.hosts.lists = []
c.content.pdfjs = True
c.downloads.prevent_mixed_content = False
c.editor.command = ['nvim', '{file}']
c.fileselect.single_file.command = ['alacritty', '-e', 'nnn', '{}']
c.fileselect.multiple_files.command = ['alacritty', '-e', 'nnn', '{}']
c.fileselect.folder.command = ['alacritty', '-e', 'nnn', '{}']
c.fonts.default_size = '11pt'
c.hints.chars = 'zxcvbnm'
c.input.mouse.rocker_gestures = True
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
c.tabs.tooltips = False
c.url.default_page = 'https://www.google.com'
c.url.searchengines = {'DEFAULT': 'https://www.google.com/search?q={}'}
c.url.start_pages = 'https://www.google.com'
c.window.title_format = '_'
c.zoom.default = '110%'

c.bindings.default['normal'] = {}
c.bindings.commands['normal'] = {
  '<Backspace>': 'back',
  '<Ctrl+q>': 'quit',
  '<Escape>': 'clear-keychain ;; search ;; fullscreen --leave',
  '<Ctrl+Left>': 'tab-prev',
  '<Ctrl+Right>': 'tab-next',
  '/': 'set-cmd-text /',
  '?': 'set-cmd-text ?',
  ':': 'set-cmd-text :',
  '\\v': 'hint links run :spawn mpv {hint-url}',
  '\\V': 'hint links run :spawn yt-dlp {hint-url}',
  '\\o': 'hint links run :open {hint-url}',
  '\\O': 'hint links run :open -t -r {hint-url}',
  '\\d': 'hint links download',
  '\\i': 'hint inputs',
  '<Del>': 'tab-close',
  '<Ctrl+Del>': 'tab-only',
  'dc': 'download-clear',
  'dx': 'download-cancel',
  'i': 'mode-enter insert',
  'm': 'quickmark-save',
  'M': 'bookmark-add',
  'n': 'search-next',
  'N': 'search-prev',
  'o': 'set-cmd-text -s :open',
  'O': 'set-cmd-text -s :open -t',
  'p': 'open - {clipboard}',
  'P': 'open -t -- {clipboard}',
  '<F5>': 'reload',
  'y': 'yank'
}

c.bindings.default['hint'] = {}
c.bindings.commands['hint'] = {
  '<Escape>': 'mode-leave',
  '<Return>': 'hint-follow'
}

c.bindings.default['command'] = {}
c.bindings.commands['command'] = {
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

c.bindings.default['prompt'] = {}
c.bindings.commands['prompt'] = {
  '<Escape>': 'mode-leave',
  '<Return>': 'prompt-accept',
  '<Up>': 'prompt-item-focus prev',
  '<Down>': 'prompt-item-focus next'
}
