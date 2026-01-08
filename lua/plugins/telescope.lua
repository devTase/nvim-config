return {
  -- FZF-lua como backup
  {
    'ibhagwan/fzf-lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons'
    },
    config = function()
      require('fzf-lua').setup({
        winopts = {
          height = 0.5,
          width = 0.5,
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

  -- Telescope - plugin principal com preview e recursos avançados
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-ui-select.nvim',
    },
    config = function()
      require('telescope').setup({
        defaults = {
          layout_strategy = 'vertical',
          layout_config = {
            vertical = {
              width = 0.7,
              height = 0.8,
              preview_cutoff = 0,
              prompt_position = 'top',
              mirror = false
            }
          },
          sorting_strategy = 'ascending',
          path_display = { 'truncate' },
          preview = {
            hide_on_startup = false,
            filesize_limit = 2, -- MB
            timeout = 200
          },
          results_title = false,
          prompt_title = false,
          borderchars = {
            prompt = { '─', '│', ' ', '│', '┌', '┐', '│', '│' },
            results = { '─', '│', '─', '│', '├', '┤', '┴', '┬' },
            preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
          }
        },
        pickers = {
          find_files = {
            find_command = { 'fd', '--type', 'f', '--strip-cwd-prefix', '--hidden', '--follow', '--exclude', '.git', '--exclude', 'node_modules' },
            previewer = true,
            layout_config = {
              vertical = {
                width = 0.7,
                height = 0.8,
                preview_cutoff = 0,
                prompt_position = 'top'
              }
            }
          },
          live_grep = {
            additional_args = function()
              return { '--hidden', '--glob', '!{.git,node_modules}' }
            end,
            previewer = true,
            layout_config = {
              vertical = {
                width = 0.75,
                height = 0.8,
                preview_cutoff = 0,
                prompt_position = 'top'
              }
            }
          },
          buffers = {
            previewer = true,
            layout_config = {
              vertical = {
                width = 0.6,
                height = 0.7,
                preview_cutoff = 0,
                prompt_position = 'top'
              }
            }
          },
          help_tags = {
            previewer = true
          }
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown({
              layout_config = {
                width = 0.5,
                height = 0.3
              }
            })
          }
        }
      })

      -- Carregar extensões
      require('telescope').load_extension('ui-select')
    end
  }
}