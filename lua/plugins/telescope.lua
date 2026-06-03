return {
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
      local telescope = require('telescope')
      telescope.setup({
        defaults = {
          layout_strategy = 'horizontal',
          layout_config = {
            height = 0.7,
            width = 0.7,
            preview_width = 0.55,
          },
          file_ignore_patterns = { '.git/', 'node_modules/' },
          hidden = true,
        },
        pickers = {
          find_files = {
            hidden = true,
          },
          live_grep = {
            additional_args = { '--hidden' },
          },
        },
      })
      telescope.load_extension('fzf')
    end,
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<CR>', desc = 'Find files' },
      { '<leader>fg', '<cmd>Telescope live_grep<CR>', desc = 'Live grep' },
    },
  },
}