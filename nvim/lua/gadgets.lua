-- autopairs package
local pairs = require("nvim-autopairs")
local rule = require("nvim-autopairs.rule")
local cond = require("nvim-autopairs.ts-conds")

pairs.setup {
    check_ts = true,
    map_cr = true,
    ts_config = {
        lua = { "string" }
    }
}

pairs.add_rules {  -- press % => %% only while inside a comment or string
  rule("%", "%", "lua")
    :with_pair(cond.is_ts_node({ "string", "comment" })),
  rule("$", "$", "lua")
    :with_pair(cond.is_not_ts_node({ "function" }))
}

-- telescope package
local sorts = require("telescope.sorters")
local previews = require("telescope.previewers")
local telescope = require("telescope")
telescope.setup {
  defaults = {
    layout_config = {
      width = 0.75,
      prompt_position = "top",
      preview_cutoff = 120,
      horizontal = { mirror = false },
      vertical = { mirror = false }
    },
    find_command = { "rg", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case" },
    prompt_prefix = " ",
    selection_caret = " ",
    entry_prefix = "  ",
    initial_mode = "insert",
    selection_strategy = "reset",
    sorting_strategy = "descending",
    layout_strategy = "horizontal",
    file_sorter = sorts.get_fuzzy_file,
    file_ignore_patterns = {},
    generic_sorter = sorts.get_generic_fuzzy_sorter,
    path_displ = {},
    winblend = 0,
    border = {},
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    color_devicons = true,
    use_less = true,
    set_env = { ["COLORTERM"] = "truecolor" },
    file_previewer = previews.vim_buffer_cat.new,
    grep_previewer = previews.vim_buffer_vimgrep.new,
    qflist_previewer = previews.vim_buffer_qflist.new,
    buffer_previewer_maker = previews.buffer_previewer_maker
  }
}

-- tree package
require("nvim-tree").setup {
  git = { ignore = false },
  open_on_tab = true,
  renderer = {
    indent_markers = { enable = true }
  },
  view = { width = 25 }
}

-- whichkey package
local wkey = require("which-key")

wkey.setup {
  popup_mappings = {
    scroll_down = "<PageDown>",
    scroll_up = "<PageUp>"
  }
}

local maps = {
  --basics
  q = { ":q!<CR>", "Quit" },
  w = { ":w!<CR>", "Save" },
  c = { ":bdelete<CR>", "Close Buffer" },
  -- tree
  e = { ":NvimTreeToggle<CR>", "File Explorer" },
  -- telescope
  f = {
    name = "Telescope",
    f = { ":Telescope find_files<CR>", "Find File" },
    g = { ":Telescope live_grep<CR>", "Live Grep" },
    b = { ":Telescope buffers<CR>", "Buffers" },
    h = { ":Telescope help_tags<CR>", "Help Tags" },
    o = { ":Telescope vim_options<CR>", "Vim Options" }
  },
  -- search and replace
  s = {
    name = "Search & Replace",
    s = { ":SearchBoxMatchAll<CR>", "Search" },
    c = { ":SearchBoxClear<CR>", "Clear" },
    n = { ":SearchBoxIncSearch<CR>", "Next" },
    r = { ":SearchBoxReplace<CR>", "Replace" }
  },
  -- LSP
  p = {
    name = "LSP",
    I = { ":LspInfo<CR>", "Info" },
    f = { ":lua vim.lsp.buf.format { async = true }<CR>", "Format" },
    l = { ":lua vim.lsp.codelens.run()<CR>", "CodeLens Action" },
    q = { ":lua vim.lsp.diagnostic.set_loclist()<CR>", "Quickfix" },
    D = { ":lua vim.lsp.buf.declaration()<CR>", "Go To Declaration" },
    d = { ":lua vim.lsp.buf.definition()<CR>", "Go To Definition" },
    c = { ":lua vim.lsp.buf.implementation()<CR>", "Go To Definition" },
    t = { ":Telescope lsp_document_diagnostics<CR>", "Document Diagnostics" },
    s = { ":Telescope lsp_document_symbols<CR>", "Document Symbols" },
    a = { ":lua vim.lsp.buf.code_action()<CR>", "Code Action" },
    r = { ":lua vim.lsp.buf.rename()<CR>", "Rename" },
    n = { ":lua vim.lsp.diagnostic.goto_next()<CR>", "Next Diagnostic" },
    p = { ":lua vim.lsp.diagnostic.goto_prev()<CR>", "Prev Diagnostic" },
    e = { ":lua vim.lsp.buf.references()<CR>", "References" },
    h = { ":lua vim.lsp.buf.hover()<CR>", "Hover" }
  }
}

wkey.register(maps, { prefix = "<leader>" })
