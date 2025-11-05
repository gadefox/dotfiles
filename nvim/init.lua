local lazy = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazy) then
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", "https://github.com/folke/lazy.nvim.git", lazy })
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

vim.opt.rtp:prepend(lazy)

-- go to last location when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    -- if a line has already been specified on the command line, we are done
    if vim.fn.line(".") > 1 then
      return
    end

    local mark = vim.api.nvim_buf_get_mark(0, "\"")
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
      vim.api.nvim_win_set_cursor(0, mark)
    end

    -- set file type
    vim.defer_fn(function()
      if vim.bo.filetype == "" then
        vim.bo.filetype = "text"
      end
    end, 0)
  end
})
 
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = ""
    }
  }
})

vim.keymap.set("n", "<tab>", "<cmd>bnext<cr>", { silent = true })
vim.keymap.set("n", "<s-tab>", "<cmd>bprevious<cr>", { silent = true })

vim.opt.clipboard = "unnamedplus" -- use system clipboard
vim.opt.ignorecase = true  -- ignore case in search patterns
vim.opt.mouse = "a" -- enable mouse support (all modes)
vim.opt.shortmess = vim.o.shortmess .. "I" -- don't give the intro message when starting vim
vim.opt.expandtab = true -- use space character instead of the tab character
vim.opt.shiftwidth = 2 -- block shift (>> << keys) indent
vim.opt.tabstop = 4 -- number of spaces that a <tab> in the file counts for

vim.opt.cursorline = true -- highlight the text line of the cursor
vim.opt.fillchars = "eob: " -- eob: empty lines at the end of a buffer
vim.opt.list = true
vim.opt.listchars = { extends = "▸", precedes = "◂", space = "⋅", tab = "→ ", trail = "·", eol = "↴", nbsp = "◇" } -- nbsp -> non-breakable space character; trail -> trailing spaces
vim.opt.number = true -- line numbers
vim.opt.pumheight = 20 -- maximum number of items to show in the popup menu
vim.opt.scrolloff = 10 -- min nr of lines to keep above and below the cursor
vim.opt.signcolumn = "yes" -- diagnostic signs
vim.opt.sidescrolloff = 15 -- the minimal number of screen columns to keep to the left and to the right of the cursor if `nowrap is set
vim.opt.wrap = false -- lines will not wrap and only part of long lines will be displayed
vim.opt.laststatus = 0 -- hide statusbar
vim.opt.statusline = string.rep("-", vim.api.nvim_win_get_width(0))

vim.lsp.set_log_level("ERROR")

local palette
local kind_icons = {
  Array = "󰅪",
  Boolean = "◩",
  Class = "󰠱",
  Color = "󰏘",
  Constant = "󰏿",
  Constructor = "",
  Enum = "󰒻",
  EnumMember = "",
  Event = "",
  Field = "",
  File = "󰈙",
  Folder = "",
  Function = "󰊕",
  Interface = "",
  Key = "",
  Keyword = "",
  Method = "󱎥",
  Macro = "󱢓",
  Module = "",
  Namespace = "󰌗",
  Null = "󰟢",
  Number = "󰎠",
  Object = "󰅩",
  Operator = "󰆕",
  Package = "",
  Parameter = "󰅲",
  Property = "󰆧",
  Reference = "󰈇",
  Snippet = "",
  StaticMethod = "󰠄",
  String = "󰀬",
  Struct = "󰙅",
  Text = "󰉿",
  TypeAlias = "",
  TypeParameter = "",
  Unit = "",
  Value = "",
  Variable = "󰀫"
}

local function set_highlight(colors)
  for hl, col in pairs(colors) do
    vim.api.nvim_set_hl(0, hl, col)
  end
end

require("lazy").setup({
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      local catppuccin = require("catppuccin")

      catppuccin.setup({
        flavour = "mocha",
        term_colors = true,
        transparent_background = true,
        integrations = {
          alpha = false,
          dap = false,
          dap_ui = false,
          dashboard = false,
          flash = false,
          fzf = false,
          gitsigns = false,
          indent_blankline = {
            enabled = false
          },
          markdown = false,
          mini = {
            enabled = false
          },
          neogit = false,
          neotree = false,
          nvimtree = false,
          render_markdown = false,
          semantic_tokens = false,
          telescope = {
            enabled = false
          },
          ufo = false
        }
      })

      catppuccin.load()
      palette = require("catppuccin.palettes").get_palette()
    end
  },

  { -- #cba6f7
    "NvChad/nvim-colorizer.lua",
    config = true
  },

  { "RRethy/vim-illuminate" }, -- automatically highlights other uses of the word under the cursor

  { -- ┊ → ↴
    "lukas-reineke/indent-blankline.nvim",
    name = "ibl",
    dependencies = {
      "HiPhish/rainbow-delimiters.nvim" -- due to `highlight definition otherwise it's not dependent
    },
    config = function()
      local config = require("rainbow-delimiters.config")

      require("ibl").setup({
        indent = {
          char = "▏"
        },
        scope = {
          highlight = config.highlight
        }
      })

      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)

      set_highlight({
        IndentBlanklineChar = { fg = palette.overlay0 },
        IndentBlanklineContextChar = { fg = palette.overlay0 }
      })
    end
  },

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
        kinds = kind_icons,
        show_modified = true
      })

      local ui = require("barbecue.ui")

      vim.api.nvim_create_autocmd({ "WinResized", "BufWinEnter", "CursorHold", "InsertLeave", "BufModifiedSet" }, {
        group = vim.api.nvim_create_augroup("barbecue.updater", {}),
        callback = function() ui.update() end
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

      set_highlight({
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
    end
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim"
    },
    config = function()
      require("telescope").setup({
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ❯ ",
          entry_prefix = "   ",
          layout_config = {
            horizontal = {
              prompt_position = "top"
            }
          }
        }
      })

      set_highlight({
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

  {
    "folke/trouble.nvim",
    config = true,
    cmd = "Trouble",
    keys = {
      {
        "<leader>xd",
        "<cmd>Trouble lsp toggle focus=false<cr>",
        desc = "LSP definitions, references ..."
      },
      {
        "<leader>xl",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location list"
      },
      {
        "<leader>xq",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix list"
      },
      {
        "<leader>xs",
        "<cmd>Trouble symbols toggle focus=true win.position=bottom<cr>",
        desc = "Symbols"
      },
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle focus=true filter.buf=0<cr>",
        desc = "Diagnostics"
      }
    }
  },

  {
    "folke/todo-comments.nvim",
    config = function()
     local todo = require("todo-comments")

      todo.setup({
        keywords = {
          FIXME = {
            icon = " ",
            color = palette.red -- FIXME:
          },
          TODO = {
            icon = " ",
            color = palette.mauve -- TODO:
          },
          HACK = {
            icon = "⋅",
            color = palette.maroon -- HACK:
          },
          WARN = {
            icon = " ",
            color = palette.peach -- WARN:
          },
          PERF = {
            icon = "⋅",
            color = palette.teal -- PERF:
          },
          NOTE = {
            icon = "󰍨⋅",
            alt = { "INFO" },
            color = palette.green -- NOTE:
          },
          TEST = {
            icon = "⋅",
            alt = { "PASS", "FAIL" },
            color = palette.blue -- TEST:
          }
        },
        colors = {}
      })

      vim.keymap.set("n", "]t", function() todo.jump_next() end, { desc = "Next todo comment" })
      vim.keymap.set("n", "[t", function() todo.jump_prev() end, { desc = "Previous todo comment" })
    end
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim"
    },
    config = function()
      require("noice").setup({
        health = {
          checker = false
        },
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true
          },
        },
        popupmenu = {
          enabled = true,
          kind_icons = kind_icons
        }
      })

      set_highlight({
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
    end
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    dependencies = {
      "echasnovski/mini.nvim"
    },
    config = function()
      local whichkey = require("which-key")

      whichkey.add({
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
        "<leader>f",
        "<cmd>lua vim.lsp.buf.format({ async = true })<cr>",
        desc = "Format"
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
      "nvim-treesitter/nvim-treesitter-textobjects"
    },
    build = ":TSUpdate",
    config = function ()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        ensure_installed = {
          "bash", "c", "cpp", "json", "lua", "markdown", "markdown_inline", "perl", "python", "regex", "vim" -- markdown/inline, regex, bash are needed by packages
        },
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
              ["]]"] = {
                query = "@function.outer",
                desc = "Go to the next function"
              }
            },
            goto_previous = {
              ["[["] = {
                query = "@function.outer",
                desc = "Go to the previous function"
              }
            }
          },
          select = { -- delete: dfc; select: vfc
            enable = true,
            lookahead = true,
            keymaps = {
              ["fc"] = {
                query = "@function.inner",
                desc = "Select inner part of a function"
              },
              ["ff"] = {
                query = "@function.outer",
                desc = "Select whole function"
              }
            }
          }
        }
      })
    end
  },

  { "nvim-treesitter/nvim-treesitter-context" }, -- shows the context of the currently visible buffer contents
  { "RRethy/nvim-treesitter-endwise" },

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
          ["<up>"] = cmp.mapping.select_prev_item(),
          ["<down>"] = cmp.mapping.select_next_item(),
          ["<page-up>"] = cmp.mapping.scroll_docs(-1),
          ["<page-down>"] = cmp.mapping.scroll_docs(1),
          ["<tab>"] = cmp.mapping.select_next_item(),
          ["<s-tab>"] = cmp.mapping.select_prev_item()
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
      local cap = require("cmp_nvim_lsp").default_capabilities()

      cap.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
      }

      vim.lsp.config("clangd", {
        cmd = { "clangd" },
        capabilities = cap,
        filetypes = { "c", "cpp", "objc", "objcpp" },
        on_attach = function(_, bufnr)
          local opts = { buffer = bufnr, noremap = true, silent = true }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>f", function()
            vim.lsp.buf.format({ async = true })
          end, opts)
        end
      })

      vim.lsp.config("lua_ls", {
        cmd = { "/usr/local/libexec/lsp-lua/bin/lua-language-server" },
        capabilities = cap
      })
    end
  },

  { "DNLHC/glance.nvim" },
})
