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
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      -- Enable LSP file operations (willRename) for refactoring on move
      capabilities.workspace = capabilities.workspace or {}
      capabilities.workspace.fileOperations = {
        dynamicRegistration = false,
        didCreate = true,
        willCreate = true,
        didRename = true,
        willRename = true,
        didDelete = true,
        willDelete = true,
      }

      -- Lua
      vim.lsp.config.lua_ls = {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { 'vim' } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      }

      -- Python
      vim.lsp.config.pyright = { capabilities = capabilities }

      -- C/C++
      vim.lsp.config.clangd = { capabilities = capabilities }

      -- Markdown
      vim.lsp.config.marksman = { capabilities = capabilities }

      -- YAML
      vim.lsp.config.yamlls = {
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
      }

      -- JSON
      vim.lsp.config.jsonls = {
        capabilities = capabilities,
        settings = {
          json = {
            schemas = require('schemastore').json.schemas(),
            validate = { enable = true },
          },
        },
      }

      vim.lsp.enable({ 'lua_ls', 'pyright', 'clangd', 'marksman', 'yamlls', 'jsonls' })
    end,
  },

  -- LSP file operations
  {
    'antosha417/nvim-lsp-file-operations',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-tree/nvim-tree.lua' },
    config = function()
      -- Fix deprecated API for Neovim 0.12+ (plugin uses get_active_clients)
      vim.lsp.get_active_clients = vim.lsp.get_clients
      require('lsp-file-operations').setup()
    end,
  },
}
