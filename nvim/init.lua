require("packer").startup(function(use)
  use "wbthomason/packer.nvim"
  use { "catppuccin/nvim", as = "catppuccin" }
  use "norcalli/nvim-colorizer.lua"
  use "lukas-reineke/indent-blankline.nvim"
  use "HiPhish/nvim-ts-rainbow2"
  use "windwp/nvim-autopairs"
  use "numToStr/Comment.nvim"
  use { "utilyre/barbecue.nvim", requires = { "nvim-tree/nvim-web-devicons", "SmiteshP/nvim-navic" } }
  use "nvim-tree/nvim-tree.lua"
  use { "folke/noice.nvim", requires = { "rcarriga/nvim-notify", "MunifTanjim/nui.nvim" } }
  use "folke/which-key.nvim"
  use { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }
  use "nvim-treesitter/nvim-treesitter-context"
  use "nvim-treesitter/nvim-treesitter-textobjects"
  use { "nvim-telescope/telescope.nvim", requires = { "nvim-lua/plenary.nvim" } }
  use { "nvim-telescope/telescope-fzf-native.nvim", run = "make" }
  use { "hrsh7th/nvim-cmp", requires = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-cmdline", "hrsh7th/cmp-path" } }
  use "neovim/nvim-lspconfig"
  use "DNLHC/glance.nvim"
  use "stevearc/oil.nvim"
end)

vim.bo.autoindent = true
vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.tabstop = 2

vim.o.autoindent = true
vim.o.backup = false
vim.o.clipboard = "unnamedplus"
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.fileencoding = "utf-8"
vim.o.hidden = true
vim.o.ignorecase = true
vim.o.mouse = "a"
vim.o.pumheight = 20  -- max popup menu height
vim.o.scrolloff = 10  -- min nr of lines to keep above and below the cursor
vim.o.sidescrolloff = 15
vim.o.shiftwidth = 2
vim.o.shortmess = vim.o.shortmess .. "I"
vim.o.softtabstop = 2
vim.o.tabstop = 2
vim.o.writebackup = false

vim.opt.laststatus = 0

vim.wo.number = true
vim.wo.signcolumn = "yes"
vim.wo.wrap = false

vim.cmd("filetype plugin indent on")

vim.keymap.set("n", "<del>", "\"_x")
vim.keymap.set("n", "<Tab>", ":bnext<CR>", { silent = true })
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", { silent = true })

vim.api.nvim_create_autocmd("BufReadPost", {  -- go to last location when opening a buffer
  callback = function()
    if vim.fn.line(".") > 1 then  -- If a line has already been specified on the command line, we are done
      return
    end

    local mark = vim.api.nvim_buf_get_mark(0, "\"")
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end
})

-- color scheme
local palette = require("catppuccin.palettes").get_palette()

local function set_hl(colors)
  for hl, col in pairs(colors) do
    vim.api.nvim_set_hl(0, hl, col)
  end
end

local catppuccin = require("catppuccin")
catppuccin.setup {
  term_colors = true,
  lsp_saga = false,
  gitgutter = false,
  gitsigns = false,
  leap = false,
  neotree = {
    enabled = false
  },
  dashboard = false,
  neogit = false,
  barbar = false,
  markdown = false,
  symbols_outline = false
}

catppuccin.load("macchiato")

-- autopairs package
require("nvim-autopairs").setup()

-- barbecue
vim.opt.updatetime = 300

require("barbecue").setup {
  create_autocmd = false,
  show_modified = true
}

local barbecue_ui = require("barbecue.ui")

vim.api.nvim_create_autocmd({
  "WinResized", "BufWinEnter", "CursorHold", "InsertLeave", "BufModifiedSet"
}, {
  group = vim.api.nvim_create_augroup("barbecue.updater", {}),
  callback = function() barbecue_ui.update() end
})

-- cmp
local lsp_icons = {
  Array = "󰅪 ",
  Boolean = "◩ ",
  Class = "󰠱 ",
  Color = " ",
  Constant = "󰏿 ",
  Constructor = " ",
  Enum = "練 ",
  EnumMember = " ",
  Event = " ",
  Field = " ",
  File = " ",
  Folder = " ",
  Function = " ",
  Interface = " ",
  Key = "󰌋 ",
  Keyword = " ",
  Method = "󰆧 ",
  Module = " ",
  Namespace = "󰌗 ",
  Null = "󰟢 ",
  Number = "󰎠 ",
  Object = "󰅩 ",
  Operator = " ",
  Package = " ",
  Property = " ",
  Reference = "󰈇 ",
  Snippet = " ",
  String = " ",
  Struct = "󰙅 ",
  Text = " ",
  TypeParameter = " ",
  Unit = " ",
  Value = " ",
  Variable = "󰀫 "
}

local context = require("cmp.config.context")
local cmp = require("cmp")

cmp.setup {
  enabled = function()
    if vim.api.nvim_get_mode().mode == "c" then
      return true
    end
    return not context.in_treesitter_capture("comment") and not context.in_syntax_group("Comment")
  end,
  formatting = {
    format = function(_, item)
      item.kind = lsp_icons[item.kind]
      return item
    end
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "path" }
  },
  mapping = cmp.mapping.preset.insert {
    ["<Up>"] = cmp.mapping.select_prev_item(),
    ["<Down>"] = cmp.mapping.select_next_item(),
    ["<Page-Up>"] = cmp.mapping.scroll_docs(-1),
    ["<Page-Down>"] = cmp.mapping.scroll_docs(1),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item()
  }
}

cmp.setup.cmdline({ "/", "?" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    {
      name = "buffer",
      option = {
        keyword_pattern = [[\k\+]]
      }
    }
  }
})

cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "cmdline" },
    { name = "path" }
  }
})

-- colorizer
require("colorizer").setup()

-- comments
require("Comment").setup {
  mappings = {
    extra = false
  }
}

-- indent blackline (┊.↴)
vim.opt.list = true
vim.opt.listchars = { trail = "·", nbsp = "◇", tab = "→ ", extends = "▸", precedes = "◂", space = "⋅", eol = "↴" }

set_hl {
  IndentBlanklineChar = { fg = palette.overlay0 },
  IndentBlanklineContextChar = { fg = palette.overlay0 }
}

require("indent_blankline").setup {
  char = "┊",
  context_char = "│",
  show_current_context = true,
  show_current_context_start = true
}

-- glance
vim.keymap.set("n", "gC", ":Glance definitions<CR>", { silent = true })
vim.keymap.set("n", "gR", ":Glance references<CR>", { silent = true })
vim.keymap.set("n", "gT", ":Glance type_definitions<CR>", { silent = true })
vim.keymap.set("n", "gI", ":Glance implementations<CR>", { silent = true })

require("glance").setup()

-- lspconfig
local signs = { Error = " ", Warn = " ", Info = " ", Hint = " " }

for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, {
    text = icon,
    texthl = hl,
    numhl = ""
  })
end

local lspcap = require("cmp_nvim_lsp").default_capabilities()
local lspcfg = require("lspconfig")

lspcfg.clangd.setup {
  capabilities = lspcap
}

lspcfg.lua_ls.setup {
  cmd = { "/usr/local/libexec/lsp-lua/bin/lua-language-server" },
  capabilities = lspcap
}

-- notify
set_hl {
  NotifyINFOBody = { bg = palette.surface0 },
  NotifyINFOBorder = { bg = palette.surface0, fg = palette.surface0 },
  NotifyINFOIcon = { bg = palette.surface0, fg = palette.green },
  NotifyINFOTitle = { bg = palette.green, fg = palette.mantle },
  NotifyWARNBody = { bg = palette.surface0 },
  NotifyWARNBorder = { bg = palette.surface0, fg = palette.surface0 },
  NotifyWARNIcon = { bg = palette.surface0, fg = palette.peach },
  NotifyWARNTitle = { bg = palette.peach, fg = palette.mantle },
  NotifyERRORBody = { bg = palette.surface0 },
  NotifyERRORBorder = { bg = palette.surface0, fg = palette.surface0 },
  NotifyERRORIcon = { bg = palette.surface0, fg = palette.red },
  NotifyERRORTitle = { bg = palette.red, fg = palette.mantle }
}

local renderbase = require("notify.render.base")

require("notify").setup {
  on_open = function(win, record)
    vim.api.nvim_win_set_config(win, {
      border = "solid",
      title = {
        {
          " " .. record.title[1] .. " ",
          "Notify" .. record.level .. "Title"
        }
      },
      title_pos = "center"
    })
  end,
  render = function(bufnr, notif, highlights)
    local namespace = renderbase.namespace()
    local length = string.len(notif.icon)

    notif.message[1] = string.format("%s %s", notif.icon, notif.message[1])
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, notif.message)

    vim.api.nvim_buf_set_extmark(bufnr, namespace, 0, 0, {
      hl_group = highlights.icon,
      end_col = length,
      priority = 50
    })
    vim.api.nvim_buf_set_extmark(bufnr, namespace, 0, length, {
      hl_group = highlights.body,
      end_line = #notif.message,
      priority = 50
    })
  end
}

-- noice
set_hl {
  NoiceCmdlinePopup = { bg = palette.surface0 },
  NoiceCmdlineIconCalculator = { bg = palette.surface0, fg = palette.flamingo },
  NoiceCmdlineIconCmdLine = { bg = palette.surface0, fg = palette.pink },
  NoiceCmdlineIconFilter = { bg = palette.surface0, fg = palette.lavender },
  NoiceCmdlineIconHelp = { bg = palette.surface0, fg = palette.green },
  NoiceCmdlineIconInput = { bg = palette.surface0, fg = palette.red },
  NoiceCmdlineIconLua = { bg = palette.surface0, fg = palette.blue },
  NoiceCmdlineIconSearch = { bg = palette.surface0, fg = palette.mauve },
  NoiceCmdlinePopupBorderCalculator = { bg = palette.surface0, fg = palette.surface0 },
  NoiceCmdlinePopupBorderCmdLine = { bg = palette.surface0, fg = palette.surface0 },
  NoiceCmdlinePopupBorderFilter = { bg = palette.surface0, fg = palette.surface0 },
  NoiceCmdlinePopupBorderHelp = { bg = palette.surface0, fg = palette.surface0 },
  NoiceCmdlinePopupBorderInput = { bg = palette.surface0, fg = palette.surface0 },
  NoiceCmdlinePopupBorderLua = { bg = palette.surface0, fg = palette.surface0 },
  NoiceCmdlinePopupBorderSearch = { bg = palette.surface0, fg = palette.surface0 },
  NoiceCmdlinePopupTitleCalculator = { bg = palette.flamingo, fg = palette.mantle },
  NoiceCmdlinePopupTitleCmdLine = { bg = palette.pink, fg = palette.mantle },
  NoiceCmdlinePopupTitleFilter = { bg = palette.lavender, fg = palette.mantle },
  NoiceCmdlinePopupTitleHelp = { bg = palette.green, fg = palette.mantle },
  NoiceCmdlinePopupTitleInput = { bg = palette.red, fg = palette.mantle },
  NoiceCmdlinePopupTitleLua = { bg = palette.blue, fg = palette.mantle },
  NoiceCmdlinePopupTitleSearch = { bg = palette.mauve, fg = palette.mantle }
}

require("noice").setup {
  health = {
    checker = false
  },
  lsp = {
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
  },
  popupmenu = {
    enabled = true
  }
}

-- oil ~ edit files and directories using the buffer
require("oil").setup {
  view_options = {
    show_hidden = true
  }
}

-- telescope
set_hl {
  TelescopeMatching = { fg = palette.flamingo },
  TelescopePreviewBorder = { bg = palette.mantle, fg = palette.mantle },
  TelescopePreviewNormal = { bg = palette.mantle },
  TelescopePreviewTitle = { bg = palette.green, fg = palette.mantle },
  TelescopePromptBorder = { bg = palette.surface0, fg = palette.surface0 },
  TelescopePromptNormal = { bg = palette.surface0 },
  TelescopePromptPrefix = { bg = palette.surface0 },
  TelescopePromptTitle = { bg = palette.pink, fg = palette.mantle },
  TelescopeResultsNormal = { bg = palette.mantle },
  TelescopeResultsBorder = { bg = palette.mantle, fg = palette.mantle },
  TelescopeResultsTitle = { fg = palette.mantle },
  TelescopeSelection = { fg = palette.text, bg = palette.surface0, bold = true }
}

local telescope = require("telescope")
telescope.setup {
  defaults = {
    prompt_prefix = "   ",
    selection_caret = "  ",
    layout_config = {
      horizontal = {
        prompt_position = "top"
      }
    }
  }
}

telescope.load_extension("fzf")

-- tree
require("nvim-tree").setup {
  git = {
    ignore = false
  },
  renderer = {
    indent_markers = {
      enable = true
    }
  },
  view = {
    width = 25
  }
}

-- treesitter
require("nvim-treesitter.configs").setup {
  ensure_installed = { "c", "cpp", "json", "lua", "perl", "python", "regex", "vim" },
  highlight = {
    enable = true
  },
  rainbow = {
    enable = true
  },
  textobjects = {
    lsp_interop = {
      enable = true,
      border = "none",
      floating_preview_opts = {},
      peek_definition_code = {
        ["<leader>sf"] = "@function.outer"
      }
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        ["]]"] = "@function.outer"
      },
      goto_next_end = {
        ["]["] = "@function.outer"
      },
      goto_previous_start = {
        ["[["] = "@function.outer"
      },
      goto_previous_end = {
        ["[]"] = "@function.outer"
      },
      goto_next = {
        ["]c"] = "@conditional.outer"
      },
      goto_previous = {
        ["[c"] = "@conditional.outer"
      }
    }
  }
}

-- whichkey
vim.o.timeout = true
vim.o.timeoutlen = 300

local wkey = require("which-key")

wkey.setup {
  popup_mappings = {
    scroll_down = "<PageDown>",
    scroll_up = "<PageUp>"
  }
}

wkey.register({
  c = { ":bdelete<CR>", "Close Buffer" },
  e = { ":NvimTreeToggle<CR>", "Explorer" },
  f = {
    name = "Telescope",
    b = { ":Telescope buffers<CR>", "Buffers" },
    c = { ":Telescope commands<CR>", "Commands" },
    d = { ":Telescope diagnostics<CR>", "Diagnostics" },
    f = { ":Telescope find_files<CR>", "Find files" },
    g = { ":Telescope live_grep<CR>", "Find text" },
    h = { ":Telescope help_tags<CR>", "Help tags" },
    l = { ":Telescope highlights<CR>", "Highlights" },
    v = { ":Telescope vim_options<CR>", "Vim options" }
  },
  o = { ":Oil<CR>", "Oil" },
  q = { ":q<CR>", "Quit" },
  s = {
    name = "LSP",
    ["?"] = { ":LspInfo<CR>", "Info" },
    c = { ":lua vim.lsp.buf.definition()<CR>", "Go to definition" },
    d = { ":lua vim.lsp.buf.declaration()<CR>", "Go to declaration" },
    i = { ":lua vim.lsp.buf.implementation()<CR>", "Go to implementation" },
    h = { ":lua vim.lsp.buf.hover()<CR>", "Hover" },
    r = { ":lua vim.lsp.buf.rename()<CR>", "Rename" }
  },
  w = { ":w<CR>", "Save" }
}, {
  prefix = "<leader>"
})
