-- vim settings
local signs = {
  { name = "DiagnosticSignError", text = "" },
  { name = "DiagnosticSignWarn", text = "" },
  { name = "DiagnosticSignInfo", text = "󰋽" },
  { name = "DiagnosticSignHint", text = "" }
}

for _, sign in ipairs(signs) do
  vim.fn.sign_define(sign.name, {
    texthl = sign.name,
    text = sign.text,
    numhl = ""
  })
end

local config = {
  virtual_text = false,
  signs = { arcite = signs },
  update_in_insert = true,
  underline = true,
  severity_sort = true,
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = ""
  }
}
vim.diagnostic.config(config)

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
  width = 60
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = "rounded",
  width = 60
})

-- lspconfig package
local lspcap = require("cmp_nvim_lsp").default_capabilities()
local lspcfg = require("lspconfig")

lspcfg.lua_ls.setup {
  cmd = { "/usr/local/libexec/lsp-lua/bin/lua-language-server" },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = {
        globals = { "vim" }
      },
      workspace = {
        library = { [vim.fn.expand("$VIMRUNTIME/lua")] = true }
      }
    }
  },
  capabilities = lspcap
}
