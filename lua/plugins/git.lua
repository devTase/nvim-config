return {
  -- Git integrations
  { 'tpope/vim-fugitive' },
  { 'lewis6991/gitsigns.nvim' },
  {
    'ThePrimeagen/git-worktree.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('git-worktree').setup({
        change_directory_command = 'cd',  -- default: 'cd'
        update_on_change = true,         -- default: true
        update_on_change_command = 'e .', -- default: 'e .'
        clearjumps_on_change = true,     -- default: true
        autopush = false                 -- default: false
      })

      -- Configurar os keymaps para o git-worktree
      local keymap = vim.keymap.set
      keymap('n', '<leader>gw', '<cmd>lua require("telescope").extensions.git_worktree.git_worktrees()<CR>', 
            { desc = 'Lista worktrees' })
      keymap('n', '<leader>gW', '<cmd>lua require("telescope").extensions.git_worktree.create_git_worktree()<CR>', 
            { desc = 'Cria novo worktree' })

      -- Carregar a extensão do telescope
      require('telescope').load_extension('git_worktree')
    end,
    keys = {
      { '<leader>gw', desc = 'Lista worktrees' },
      { '<leader>gW', desc = 'Cria novo worktree' },
    },
  },
}
