local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", "https://github.com/folke/lazy.nvim.git", lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.api.nvim_create_autocmd("BufReadPost", { -- go to last location when opening a buffer
  callback = function()
    if vim.fn.line(".") > 1 then -- If a line has already been specified on the command line, we are done
      return
    end

    local mark = vim.api.nvim_buf_get_mark(0, "\"")
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end
})

vim.bo.autoindent = true
vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.tabstop = 2

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

local hlrainbow = { "RainbowRed", "RainbowYellow", "RainbowBlue", "RainbowOrange", "RainbowGreen", "RainbowViolet", "RainbowCyan" }
vim.g.rainbow_delimiters = { highlight = hlrainbow }

vim.o.autoindent = true
vim.o.backup = false
vim.o.clipboard = "unnamedplus"
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.fileencoding = "utf-8"
-- vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.hidden = true
vim.o.ignorecase = true
vim.o.mouse = "a"
vim.o.pumheight = 20 -- max popup menu height
vim.o.scrolloff = 10 -- min nr of lines to keep above and below the cursor
vim.o.sidescrolloff = 15
vim.o.shiftwidth = 2
vim.o.shortmess = vim.o.shortmess .. "I"
vim.o.softtabstop = 2
vim.o.tabstop = 2
vim.o.timeout = true
vim.o.timeoutlen = 300
vim.o.writebackup = false

vim.opt.laststatus = 0
vim.opt.list = true
vim.opt.listchars = { trail = "·", nbsp = "◇", tab = "→ ", extends = "▸", precedes = "◂", space = "⋅", eol = "↴" }
vim.opt.rtp:prepend(lazypath)
vim.opt.termguicolors = true
vim.opt.updatetime = 300

vim.wo.number = true
vim.wo.signcolumn = "yes"
vim.wo.wrap = false

vim.cmd("filetype plugin indent on")

vim.keymap.set("n", "<del>", "\"_x")
vim.keymap.set("n", "<tab>", "<cmd>bnext<cr>", { silent = true })
vim.keymap.set("n", "<s-tab>", "<cmd>bprevious<cr>", { silent = true })

local function set_highlight(colors)
  for hl, col in pairs(colors) do
    vim.api.nvim_set_hl(0, hl, col)
  end
end

local kind_icons = {
  Array = "󰅪 ",
  Boolean = "◩ ",
  Class = "󰠱 ",
  Color = "󰏘 ",
  Constant = "󰏿 ",
  Constructor = " ",
  Enum = " ",
  EnumMember = " ",
  Event = " ",
  Field = " ",
  File = " ",
  Folder = " ",
  Function = "󰊕 ",
  Interface = " ",
  Key = "󰌋 ",
  Keyword = "󰌋 ",
  Method = "󰆧 ",
  Module = " ",
  Namespace = "󰌗 ",
  Null = "󰟢 ",
  Number = "󰎠 ",
  Object = "󰅩 ",
  Operator = "󰆕 ",
  Package = " ",
  Property = " ",
  Reference = "󰈇 ",
  Snippet = " ",
  String = " ",
  Struct = "󰙅 ",
  Text = " ",
  TypeParameter = "󰅲 ",
  Unit = " ",
  Value = "󰎠 ",
  Variable = "󰀫 "
}

local signs = { Error = "󰅙 ", Warn = " ", Info = "󰋼 ", Hint = " " }

for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, {
    text = icon,
    texthl = hl,
    numhl = ""
  })
end

require("lazy").setup({
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
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

      local palette = require("catppuccin.palettes").get_palette()
      set_highlight({
        IndentBlanklineChar = { fg = palette.overlay0 },
        IndentBlanklineContextChar = { fg = palette.overlay0 },
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
        NoiceCmdlinePopupTitleSearch = { bg = palette.mauve, fg = palette.mantle },
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
        NotifyERRORTitle = { bg = palette.red, fg = palette.mantle },
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
    end
  },

  { -- #ff0000
    "NvChad/nvim-colorizer.lua",
    event = "BufReadPre",
    config = true
  },

  { "RRethy/vim-illuminate" }, -- automatically highlights other uses of the word under the cursor

  { -- (┊.↴)
    "lukas-reineke/indent-blankline.nvim",
    name = "ibl",
    config = function()
      local hooks = require("ibl.hooks")

      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        set_highlight({
          RainbowRed = { fg = "#e06c75" },
          RainbowYellow = { fg = "#e5c07b" },
          RainbowBlue = { fg = "#61afef" },
          RainbowOrange = { fg = "#d19a66" },
          RainbowGreen = { fg = "#98c379" },
          RainbowViolet = { fg = "#c678dd" },
          RainbowCyan = { fg = "#56b6c2" },
        })
      end)

      require("ibl").setup({
        indent = {
          char = "▏"
        },
        scope = {
          highlight = hlrainbow
        }
      })
    end
  },

  { "HiPhish/rainbow-delimiters.nvim" },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true
  },

  {
    "numToStr/Comment.nvim",
    opts = {
      toggler = {
        block = "gb"
      },
      extra = {
        above = "gca",
        below = "gcb",
        eol = "gce"
      }
    }
  },

  { -- folding
    "kevinhwang91/nvim-ufo",
    dependencies = {
      "kevinhwang91/promise-async"
    },
    opts = {
      provider_selector = function()
        return { "treesitter", "indent" }
      end,
      fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = string.format(" 󰁂 %d ", endLnum - lnum)
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
              suffix = suffix .. string.rep(" ", targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end

        local rAlignAppndx = math.max(math.min(vim.opt.textwidth["_value"], width - 1) - curWidth - sufWidth, 0)
        suffix = string.rep(" ", rAlignAppndx) .. suffix
        table.insert(newVirtText, { suffix, "MoreMsg" })
        return newVirtText
      end
    }
  },

  { -- VS Code like winbar
    "utilyre/barbecue.nvim",
    name = "barbecue",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons"
    },
    config = function()
      require("barbecue").setup({
        create_autocmd = false,
        show_modified = true,
        theme = "catppuccin"
      })

      local barbecue_ui = require("barbecue.ui")

      vim.api.nvim_create_autocmd({ "WinResized", "BufWinEnter", "CursorHold", "InsertLeave", "BufModifiedSet" }, {
        group = vim.api.nvim_create_augroup("barbecue.updater", {}),
        callback = function() barbecue_ui.update() end
      })
    end
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = {
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
  },

  {
    "rcarriga/nvim-notify",
    config = function()
      local renderbase = require("notify.render.base")
      local palette = require("catppuccin.palettes").get_palette()

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
    end
  },

  { -- diagnostics ...
    "folke/trouble.nvim",
    config = true,
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics",
      },
      {
        "<leader>xs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols",
      },
      {
        "<leader>cd",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP definitions, references ...",
      },
      {
        "<leader>xl",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location list",
      },
      {
        "<leader>xq",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix list",
      }
    }
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim"
    },
    opts = {
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
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    dependencies = {
      "echasnovski/mini.nvim"
    },
    config = function()
      local wk = require("which-key")
      wk.add({
        {
          "<leader>g",
          group = "Glance"
        },
        {
          "<leader>l",
          group = "LSP"
        },
        {
          "<leader>s",
          group = "Select"
        },
        {
          "<leader>t",
          group = "Telescope"
        },
        {
          "<leader>x",
          group = "Trouble"
        }
      })
    end,
    keys = {
      {
        "<leader>c",
        "<cmd>bdelete<cr>",
        desc = "Close Buffer"
      },
      {
        "<leader>e",
        "<cmd>NvimTreeToggle<cr>",
        desc = "Explorer"
      },
      {
        "<leader>gd",
        "<cmd>Glance definitions<cr>",
        desc = "Definition"
      },
      {
        "<leader>gi",
        "<cmd>Glance implementations<cr>",
        desc = "Implementation"
      },
      {
        "<leader>gr",
        "<cmd>Glance references<cr>",
        desc = "References"
      },
      {
        "<leader>gt",
        "<cmd>Glance type_definitions<cr>",
        desc = "Type"
      },
      {
        "<leader>p",
        "<cmd>Lazy update<cr>",
        desc = "Update plugins"
      },
      {
        "<leader>q",
        "<cmd>q<cr>",
        desc = "Quit"
      },
      {
        "<leader>l?",
        "<cmd>LspInfo<cr>",
        desc = "Info"
      },
      {
        "<leader>lc",
        "<cmd>lua vim.lsp.buf.declaration()<cr>",
        desc = "Go to declaration"
      },
      {
        "<leader>ld",
        "<cmd>lua vim.lsp.buf.definition()<cr>",
        desc = "Go to definition"
      },
      {
        "<leader>li",
        "<cmd>lua vim.lsp.buf.implementation()<cr>",
        desc = "Go to implementation"
      },
      {
        "<leader>lh",
        "<cmd>lua vim.lsp.buf.hover()<cr>",
        desc = "Hover"
      },
      {
        "<leader>lr",
        "<cmd>lua vim.lsp.buf.rename()<cr>",
        desc = "Rename"
      },
      {
        "<leader>tb",
        "<cmd>Telescope buffers<cr>",
        desc = "Buffers"
      },
      {
        "<leader>tc",
        "<cmd>Telescope commands<cr>",
        desc = "Commands"
      },
      {
        "<leader>td",
        "<cmd>Telescope diagnostics<cr>",
        desc = "Diagnostics"
      },
      {
        "<leader>tf",
        "<cmd>Telescope find_files<cr>",
        desc = "Find files"
      },
      {
        "<leader>tg",
        "<cmd>Telescope live_grep<cr>",
        desc = "Find text"
      },
      {
        "<leader>th",
        "<cmd>Telescope help_tags<cr>",
        desc = "Help tags"
      },
      {
        "<leader>tl",
        "<cmd>Telescope highlights<cr>",
        desc = "Highlights"
      },
      {
        "<leader>tr",
        "<cmd>Telescope oldfiles<cr>",
        desc = "Recept files"
      },
      {
        "<leader>tv",
        "<cmd>Telescope vim_options<cr>",
        desc = "Vim options"
      },
      {
        "<leader>w",
        "<cmd>write<cr>",
        desc = "Save Buffer"
      }
    }
  },

  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-context",
      "nvim-treesitter/nvim-treesitter-textobjects"
    },
    build = ":TSUpdate",
    config = function ()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        ensure_installed = { "c", "cpp", "json", "lua", "perl", "python", "markdown", "markdown_inline", "vim" },
        auto_install = true,
        highlight = {
          enable = true
        },
        endwise = {
          enable = true
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<leader>ss",
            node_incremental = "<leader>ss",
            node_decremental = "<leader>sd"
          },
        },
        textobjects = {
          move = {
            enable = true,
            set_jumps = true,
            goto_next = {
              ["]]"] = { query = "@function.outer", desc = "Go to the next function" }
            },
            goto_previous = {
              ["[["] = { query = "@function.outer", desc = "Go to the previous function" }
            }
          },
          select = { -- delete: dfc; select: vfc
            enable = true,
            lookahead = true,
            keymaps = {
              ["fc"] = { query = "@function.inner", desc = "Select inner part of a function" },
              ["ff"] = { query = "@function.outer", desc = "Select whole function" }
            }
          }
        }
      })
    end
  },

  { "RRethy/nvim-treesitter-endwise" },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim"
    },
    opts = {
      defaults = {
        prompt_prefix = "   ",
        selection_caret = " ❯ ",
        entry_prefix = "   ",
        layout_config = {
          horizontal = {
            prompt_position = "top"
          }
        }
      }
    }
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-path"
    },
    config = function()
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
            item.kind = kind_icons[item.kind]
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
    end
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspcfg = require("lspconfig")
      local lspcap = require("cmp_nvim_lsp").default_capabilities()

      lspcap.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
      }

      lspcfg.clangd.setup({
        capabilities = lspcap
      })

      lspcfg.lua_ls.setup({
        cmd = { "/usr/local/libexec/lsp-lua/bin/lua-language-server" },
        capabilities = lspcap
      })
    end
  },

  {
    "DNLHC/glance.nvim",
    config = true
  },
})
