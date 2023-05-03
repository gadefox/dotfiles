-- packer package
require("packer").startup(function(use)
  use "wbthomason/packer.nvim"  -- this

  use "lunarvim/darkplus.nvim"  -- theme
  use "norcalli/nvim-colorizer.lua"  -- #AB12CD
  use "lukas-reineke/indent-blankline.nvim"  -- |↴.

  use "p00f/nvim-ts-rainbow"  -- colorized { { } }
  use "windwp/nvim-autopairs"
  use "terrortylor/nvim-comment"

  use { "VonHeikemen/searchbox.nvim", requires = {
    "MunifTanjim/nui.nvim" } }

  use "nvim-tree/nvim-web-devicons"
  use "tamton-aquib/staline.nvim"
  use { "akinsho/bufferline.nvim", tag = "v3.*" }

  use { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }
  use "nvim-treesitter/nvim-treesitter-context"

  use "nvim-tree/nvim-tree.lua"
  use "folke/which-key.nvim"

  use { "nvim-telescope/telescope.nvim", tag = "0.1.1", requires = {
    "nvim-lua/plenary.nvim" } }

  use "neovim/nvim-lspconfig"  -- collection of configurations for built-in LSP client
  use "hrsh7th/nvim-cmp"  -- autocompletion plugin
  use "hrsh7th/cmp-buffer"  -- buffer completions
  use "hrsh7th/cmp-path"  -- path completions
  use "hrsh7th/cmp-cmdline"  -- cmdline completions
  use "hrsh7th/cmp-nvim-lsp"  -- LSP source for nvim-cmp
  use "L3MON4D3/LuaSnip"  -- snippets source for nvim-cmp
  use "saadparwaiz1/cmp_luasnip"  -- snippets plugin
end)
