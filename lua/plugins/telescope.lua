return {
  -- FZF-lua - plugin único e estável
  {
    'ibhagwan/fzf-lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons'
    },
    config = function()
      require('fzf-lua').setup({
        winopts = {
          height = 0.7,
          width = 0.7,
          row = 0.5,
          col = 0.5,
          border = 'rounded',
          preview = {
            hidden = false,
            vertical = 'down:50%',
            horizontal = 'right:60%'
          }
        },
        fzf_opts = {
          ['--layout'] = 'reverse-list',
          ['--info'] = 'inline-right',
          ['--border'] = 'rounded'
        },
        -- Configurações específicas para cada tipo de busca
        files = {
          cmd = 'fd',
          file_icons = true,
          color_icons = true,
          git_status = true,
          find_opts = '--type f --strip-cwd-prefix --hidden --follow --exclude .git --exclude node_modules',
          previewer = true
        },
        grep = {
          rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --hidden --glob '!{.git,node_modules}'",
          git_icons = false,
          file_icons = false
        },
        live_grep = {
          rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --hidden --glob '!{.git,node_modules}'",
          git_icons = false,
          file_icons = false
        },
        buffers = {
          sort_lastused = true,
          show_all_buffers = true,
          file_icons = true,
          color_icons = true
        },
        help_tags = {
          previewer = true
        },
        lsp = {
          code_actions = {
            previewer = 'codeaction_native'
          },
          definitions = {
            previewer = true
          },
          implementations = {
            previewer = true  
          },
          type_definitions = {
            previewer = true
          },
          references = {
            previewer = true
          }
        }
      })
    end
  }
}