return {
  -- LSP core
  {
    'neovim/nvim-lspconfig',
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'b0o/schemastore.nvim',
    },
    config = function()
      local lspconfig = require('lspconfig')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Lua
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { 'vim' } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })

      -- Python
      lspconfig.pyright.setup({ capabilities = capabilities })

      -- C/C++
      lspconfig.clangd.setup({ capabilities = capabilities })

      -- Markdown
      lspconfig.marksman.setup({ capabilities = capabilities })

      -- YAML
      lspconfig.yamlls.setup({
        capabilities = capabilities,
        settings = {
          yaml = {
            schemas = {
              ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
              ["https://json.schemastore.org/github-action.json"] = "/action.{yml,yaml}",
              ["https://json.schemastore.org/kustomization.json"] = "kustomization.{yml,yaml}",
            },
            validate = true,
            completion = true,
            hover = true,
          },
        },
      })

      -- JSON
      lspconfig.jsonls.setup({
        capabilities = capabilities,
        settings = {
          json = {
            schemas = require('schemastore').json.schemas(),
            validate = { enable = true },
          },
        },
      })
    end,
  },

  -- LSP file operations
  {
    'antosha417/nvim-lsp-file-operations',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-tree/nvim-tree.lua' },
    config = function()
      require('lsp-file-operations').setup()
    end,
  },
}
