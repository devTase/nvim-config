return {
  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    opts = {
      ensure_installed = {
        'lua', 'vim', 'query', 'json', 'yaml', 'bash', 'regex',
        'markdown', 'markdown_inline',
        'java', 'python', 'c', 'cpp',
      },
      highlight = { enable = true, additional_vim_regex_highlighting = false },
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end,
  },
}
