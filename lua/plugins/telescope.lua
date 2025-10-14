return {
  -- FZF-lua for more stable UI
  {
    'ibhagwan/fzf-lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons'
    },
    config = function()
      require('fzf-lua').setup({
        winopts = {
          height = 0.4,
          width = 0.4,
          preview = {
            hidden = 'hidden'
          }
        },
        fzf_opts = {
          ['--layout'] = 'reverse'
        }
      })
    end
  },

  -- Keep Telescope for other features
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      -- Desativa eventos automáticos problemáticos
      vim.api.nvim_create_autocmd({ 'VimEnter', 'BufEnter', 'BufWinEnter', 'FileType' }, {
        callback = function() end,
        pattern = '*',
        group = vim.api.nvim_create_augroup('DisableAutoResizeEvents', { clear = true })
      })

      -- Configuração mais conservadora do Telescope
      require('telescope').setup({
        defaults = {
          layout_strategy = 'center',
          layout_config = {
            center = {
              width = function()
                local columns = vim.o.columns
                local width = math.floor(columns * 0.5)
                return math.min(width, 80)
              end,
              height = function()
                local lines = vim.o.lines
                local height = math.floor(lines * 0.5)
                return math.min(height, 20)
              end
            }
          },
          sorting_strategy = 'ascending',
          path_display = { 'truncate' },
          preview = false,
          results_title = false,
          prompt_title = false
        },
        pickers = {
          find_files = {
            theme = 'dropdown',
            previewer = false,
            layout_config = {
              width = function()
                local columns = vim.o.columns
                local width = math.floor(columns * 0.4)
                return math.min(width, 60)
              end,
              height = function()
                local lines = vim.o.lines
                local height = math.floor(lines * 0.4)
                return math.min(height, 15)
              end
            }
          },
          -- Configurações similares para outros pickers
          buffers = {
            theme = 'dropdown',
            previewer = false,
            layout_config = {
              width = function()
                local columns = vim.o.columns
                local width = math.floor(columns * 0.4)
                return math.min(width, 60)
              end,
              height = function()
                local lines = vim.o.lines
                local height = math.floor(lines * 0.4)
                return math.min(height, 15)
              end
            }
          },
          live_grep = {
            theme = 'dropdown',
            previewer = false,
            layout_config = {
              width = function()
                local columns = vim.o.columns
                local width = math.floor(columns * 0.4)
                return math.min(width, 60)
              end,
              height = function()
                local lines = vim.o.lines
                local height = math.floor(lines * 0.4)
                return math.min(height, 15)
              end
            }
          }
        }
      })
    end
  }
}
