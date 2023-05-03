-- global settings
vim.bo.autoindent = true
vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.tabstop = 2

vim.o.autoindent = true
vim.o.backup = false
vim.o.clipboard = "unnamedplus"
vim.o.cmdheight = 1
vim.o.conceallevel = 0
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.fileencoding = "utf-8"
vim.o.hidden = true
vim.o.hlsearch = false
vim.o.ignorecase = true
vim.o.mouse = "a"
vim.o.pumheight = 20
vim.o.scrolloff = 3
vim.o.sidescrolloff = 5
vim.o.shiftwidth = 2
vim.o.shortmess = vim.o.shortmess .. "c"
vim.o.showmode = false
vim.o.softtabstop = 2
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.tabstop = 2
vim.o.timeoutlen = 100
vim.o.updatetime = 300
vim.o.whichwrap = "b,s,<,>,[,],h,l"
vim.o.writebackup = false

vim.wo.number = true
vim.wo.signcolumn = "yes"
vim.wo.wrap = false

vim.cmd("colorscheme darkplus")
vim.cmd("filetype plugin indent on")

-- bufferline package
vim.opt.termguicolors = true
vim.opt.laststatus = 2
vim.opt.showtabline = 2

require("bufferline").setup()

local key = vim.api.nvim_set_keymap

key("n", "<Tab>", ":BufferLineCycleNext<CR>", { noremap = true, silent = true })
key("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { noremap = true, silent = true })

-- colorizer package
require("colorizer").setup()

-- indent blackline package
vim.opt.list = true
vim.opt.listchars:append "space:⋅"
vim.opt.listchars:append "eol:↴"

require("indent_blankline").setup {
  show_current_context = true,
  show_current_context_start = true,
  show_end_of_line = true,
  space_char_blankline = " "
}

-- staline package
local percentage = function()
  local current_line = vim.fn.line(".")
  local total_lines = vim.fn.line("$")
  local chars = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }
  local line_ratio = current_line / total_lines
  local index = math.ceil(line_ratio * #chars)

  return chars[index]
end

require("staline").setup {
  sections = {
    left = { "mode" },
    mid = { "file_name" },
    right = { "lsp", percentage }
  },
  -- mode_colors = { i = "#C4A7E7", c = "#EBBCBA", v = "#F6C177" },
  special_table = {
    NvimTree = { "File Explorer", " " },
    packer = { "Packer", " " },
    TelescopePrompt = { "Telescope", " " }
  },
  lsp_symbols = { Error = " ", Info = "󰋽 ", Warn = " ", Hint = " " }
}

-- treesitter package
require("nvim-treesitter.configs").setup {
  ensure_installed = { "c", "lua" },
  sync_install = false,
  auto_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false
  },
  autotag = { enable = true },
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = nil
  }
}

-- comment package
require("nvim_comment").setup {
  comment_empty = false
}
