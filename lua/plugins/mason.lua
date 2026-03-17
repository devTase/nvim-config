return {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    cmd = "Mason",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "jdtls",
          "java-debug-adapter",
          "java-test",
          "clangd",
          "lua_ls",
          "pyright",
          "marksman",
          "yamlls",
          "jsonls",
        },
        PATH = "prepend",
        automatic_installation = true,
      })
    end,
  },
}