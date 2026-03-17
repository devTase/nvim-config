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
      ensure_installed = {
        "java-debug-adapter",
        "java-test",
        "prettierd",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      -- mason doesn't auto-install non-LSP tools; do it manually
      local registry = require("mason-registry")
      for _, name in ipairs(opts.ensure_installed or {}) do
        local ok, pkg = pcall(registry.get_package, name)
        if ok and not pkg:is_installed() then
          pkg:install()
        end
      end
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "jdtls",
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