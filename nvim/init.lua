-- packer package
local install = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
local glob = vim.fn.glob(install)
if vim.fn.empty(glob) > 0 then
  vim.fn.system({
    "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install
  })
  vim.api.nvim_command("packadd packer.nvim")
end

require("packer").startup(function(use)
  use "wbthomason/packer.nvim"
  use { "catppuccin/nvim", as = "catppuccin" }
  use "norcalli/nvim-colorizer.lua"
  use "RRethy/vim-illuminate"
  use "lukas-reineke/indent-blankline.nvim"
  use "HiPhish/rainbow-delimiters.nvim"
  use "windwp/nvim-autopairs"
  use "numToStr/Comment.nvim"
  use { "kevinhwang91/nvim-ufo", requires = "kevinhwang91/promise-async" }
  use { "utilyre/barbecue.nvim", requires = { "nvim-tree/nvim-web-devicons", "SmiteshP/nvim-navic" } }
  use "nvim-tree/nvim-tree.lua"
  use { "folke/noice.nvim", requires = { "rcarriga/nvim-notify", "MunifTanjim/nui.nvim" } }
  use { "folke/which-key.nvim", requires = { "echasnovski/mini.nvim" } }
  use "lewis6991/gitsigns.nvim"
  use { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }
  use "nvim-treesitter/nvim-treesitter-context"
  use "nvim-treesitter/nvim-treesitter-textobjects"
  use { "nvim-telescope/telescope.nvim", requires = { "nvim-lua/plenary.nvim" } }
  use { "nvim-telescope/telescope-fzf-native.nvim", run = "make" }
  use { "hrsh7th/nvim-cmp", requires = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-cmdline", "hrsh7th/cmp-path" } }
  use "neovim/nvim-lspconfig"
  use "DNLHC/glance.nvim"
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
vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
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
catppuccin.setup({
  term_colors = true,
  transparent_background = true,
  integrations = {
    alpha = false,
    dashboard = false,
    flash = false,
    markdown = false,
    neogit = false,
    dap = {
      enabled = false,
      enable_ui = false,
    },
    navic = { enabled = true },
    notify = true,
    telescope = { enabled = false },
    treesitter_context = true,
    which_key = true 
  }
})
catppuccin.load()

-- autopairs package
require("nvim-autopairs").setup()

-- barbecue
vim.opt.updatetime = 300

require("barbecue").setup({
  create_autocmd = false,
  show_modified = true,
  theme = "catppuccin"
})

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

cmp.setup({
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
})

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
require("Comment").setup({
  mappings = {
    extra = false
  }
})

-- indent blackline (┊.↴)
vim.opt.list = true
vim.opt.listchars = { trail = "·", nbsp = "◇", tab = "→ ", extends = "▸", precedes = "◂", space = "⋅", eol = "↴" }

set_hl({
  IndentBlanklineChar = { fg = palette.overlay0 },
  IndentBlanklineContextChar = { fg = palette.overlay0 }
})

require("ibl").setup()

-- gitsigns
require("gitsigns").setup({
  current_line_blame = true
})

-- glance
require("glance").setup()

-- illuminate
require("illuminate")

-- lspconfig
local signs = {
  Error = " ",
  Warn = " ",
  Info = " ",
  Hint = " "
}

for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, {
    text = icon,
    texthl = hl,
    numhl = ""
  })
end

local lspcfg = require("lspconfig")
local lspcap = require("cmp_nvim_lsp").default_capabilities()

lspcfg.clangd.setup({
  capabilities = lspcap
})

lspcfg.lua_ls.setup({
  cmd = { "/usr/local/libexec/lsp-lua/bin/lua-language-server" },
  capabilities = lspcap
})

-- notify
set_hl({
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
})

local renderbase = require("notify.render.base")

require("notify").setup({
  background_colour = palette.surface0,
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
})

-- noice
set_hl({
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
})

require("noice").setup({
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
})

-- telescope
set_hl({
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
})

local telescope = require("telescope")
telescope.setup({
  defaults = {
    prompt_prefix = "   ",
    selection_caret = "  ",
    layout_config = {
      horizontal = {
        prompt_position = "top"
      }
    }
  }
})

telescope.load_extension("fzf")

-- tree
require("nvim-tree").setup({
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
})

-- treesitter
require("nvim-treesitter.configs").setup({
  ensure_installed = { "c", "cpp", "json", "lua", "perl", "python", "regex", "vim" },
  highlight = {
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
})

-- ufo folding
local ufo = require("ufo")
ufo.setup({
  fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
    local newVirtText = {}
    local suffix = (' 󰁂 %d '):format(endLnum - lnum)
    local sufWidth = vim.fn.strdisplaywidth(suffix)
    local targetWidth = width - sufWidth
    local curWidth = 0

    for _, chunk in ipairs(virtText) do
      local chunkText = chunk[1]
      local chunkWidth = vim.fn.strdisplaywidth(chunkText)

      if targetWidth > curWidth + chunkWidth then
        table.insert(newVirtText, chunk)
      else
        local hlGroup = chunk[2]

        chunkText = truncate(chunkText, targetWidth - curWidth)
        table.insert(newVirtText, { chunkText, hlGroup })
        chunkWidth = vim.fn.strdisplaywidth(chunkText)

        -- str width returned from truncate() may less than 2nd argument, need padding
        if curWidth + chunkWidth < targetWidth then
          suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
        end
        break
      end
      curWidth = curWidth + chunkWidth
    end

    table.insert(newVirtText, { suffix, 'MoreMsg' })
    return newVirtText
  end,
  provider_selector = function(bufnr, filetype, buftype)
    return { "treesitter", "indent" }
  end
})

-- whichkey
vim.o.timeout = true
vim.o.timeoutlen = 300

local wkey = require("which-key")

wkey.setup({
  keys = {
    scroll_down = "<PageDown>",
    scroll_up = "<PageUp>"
  }
})

wkey.add({
  { "<leader>b", function()
    catppuccin.options.transparent_background = not catppuccin.options.transparent_background
    catppuccin.compile()
    vim.cmd.colorscheme(vim.g.colors_name)
  end, desc = "Toggle transparent background" },
  { "<leader>c", desc = "Close Buffer", ":bdelete<CR>" },
  { "<leader>e", desc = "Explorer", ":NvimTreeToggle<CR>" },
  { "<leader>f", group = "Folding" },
  { "<leader>fc", desc = "Close all folds", function() ufo.closeAllFolds() end },
  { "<leader>fo", desc = "Open all folds", function() ufo.openAllFolds() end },
  { "<leader>g", group = "Glance" },
  { "<leader>gd", desc = "Definition", ":Glance definitions<CR>" },
  { "<leader>gi", desc = "Implementation", ":Glance implementations<CR>" },
  { "<leader>gr", desc = "References", ":Glance references<CR>" },
  { "<leader>gt", desc= "Type", ":Glance type_definitions<CR>" },
  { "<leader>p", desc = "Update Plugins", ":PackerUpdate<CR>" },
  { "<leader>q", desc = "Quit", ":q<CR>" },
  { "<leader>s", group = "LSP" },
  { "<leader>s?", desc = "Info", ":LspInfo<CR>" },
  { "<leader>sc", desc = "Go to definition", ":lua vim.lsp.buf.definition()<CR>" },
  { "<leader>sd", desc = "Go to declaration", ":lua vim.lsp.buf.declaration()<CR>" },
  { "<leader>si", desc = "Go to implementation", ":lua vim.lsp.buf.implementation()<CR>" },
  { "<leader>sh", desc = "Hover", ":lua vim.lsp.buf.hover()<CR>" },
  { "<leader>sr", desc = "Rename", ":lua vim.lsp.buf.rename()<CR>" },
  { "<leader>t", group = "Telescope" },
  { "<leader>tb", desc = "Buffers", ":Telescope buffers<CR>" },
  { "<leader>tc", desc = "Commands", ":Telescope commands<CR>" },
  { "<leader>td", desc = "Diagnostics", ":Telescope diagnostics<CR>" },
  { "<leader>tf", desc = "Find files", ":Telescope find_files<CR>" },
  { "<leader>tg", desc = "Find text", ":Telescope live_grep<CR>" },
  { "<leader>th", desc = "Help tags", ":Telescope help_tags<CR>" },
  { "<leader>tl", desc = "Highlights", ":Telescope highlights<CR>" },
  { "<leader>tr", desc = "Recept files", ":Telescope oldfiles<CR>" },
  { "<leader>tv", desc = "Vim options", ":Telescope vim_options<CR>" },
  { "<leader>w", desc = "Save Buffer", ":write<CR>" }
})
