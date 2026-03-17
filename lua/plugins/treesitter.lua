return {
  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    opts = {
      ensure_installed = {
        'lua', 'vim', 'query', 'json', 'yaml', 'bash', 'regex',
        'markdown', 'markdown_inline',
        'java', 'python', 'c', 'cpp',
      },
      highlight = { enable = true, additional_vim_regex_highlighting = false },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = { query = "@function.outer", desc = "Around function/method" },
            ["if"] = { query = "@function.inner", desc = "Inside function/method" },
            ["ac"] = { query = "@class.outer", desc = "Around class" },
            ["ic"] = { query = "@class.inner", desc = "Inside class" },
            ["aa"] = { query = "@parameter.outer", desc = "Around parameter" },
            ["ia"] = { query = "@parameter.inner", desc = "Inside parameter" },
            ["ai"] = { query = "@conditional.outer", desc = "Around conditional" },
            ["ii"] = { query = "@conditional.inner", desc = "Inside conditional" },
            ["al"] = { query = "@loop.outer", desc = "Around loop" },
            ["il"] = { query = "@loop.inner", desc = "Inside loop" },
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]m"] = { query = "@function.outer", desc = "Next method start" },
            ["]]"] = { query = "@class.outer", desc = "Next class start" },
          },
          goto_next_end = {
            ["]M"] = { query = "@function.outer", desc = "Next method end" },
            ["]["] = { query = "@class.outer", desc = "Next class end" },
          },
          goto_previous_start = {
            ["[m"] = { query = "@function.outer", desc = "Previous method start" },
            ["[["] = { query = "@class.outer", desc = "Previous class start" },
          },
          goto_previous_end = {
            ["[M"] = { query = "@function.outer", desc = "Previous method end" },
            ["[]"] = { query = "@class.outer", desc = "Previous class end" },
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ["<leader>sa"] = { query = "@parameter.inner", desc = "Swap with next parameter" },
          },
          swap_previous = {
            ["<leader>sA"] = { query = "@parameter.inner", desc = "Swap with previous parameter" },
          },
        },
      },
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end,
  },
}
