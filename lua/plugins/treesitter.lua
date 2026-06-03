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

      -- HACK: Neovim 0.12 changed captures to TSNode[] (lists) but
      -- nvim-treesitter query_predicates still expect single nodes.
      -- Re-register the affected directives with a first-node unwrap.
      -- Remove this block once nvim-treesitter ships a fix upstream.
      if vim.fn.has('nvim-0.12') == 1 then
        local query = require('vim.treesitter.query')
        local force = { force = true }

        local function first(val)
          return type(val) == 'table' and not val.range and val[1] or val
        end

        query.add_directive('set-lang-from-info-string!', function(match, _, bufnr, pred, metadata)
          local node = first(match[pred[2]])
          if not node then return end
          local alias = vim.treesitter.get_node_text(node, bufnr):lower()
          local ft = vim.filetype.match({ filename = 'a.' .. alias })
          metadata['injection.language'] = ft or alias
        end, force)

        query.add_directive('set-lang-from-mimetype!', function(match, _, bufnr, pred, metadata)
          local node = first(match[pred[2]])
          if not node then return end
          local mime = vim.treesitter.get_node_text(node, bufnr)
          local langs = { ['importmap']='json', ['module']='javascript',
            ['application/ecmascript']='javascript', ['text/ecmascript']='javascript' }
          if langs[mime] then
            metadata['injection.language'] = langs[mime]
          else
            local parts = vim.split(mime, '/', {})
            metadata['injection.language'] = parts[#parts]
          end
        end, force)

        query.add_directive('downcase!', function(match, _, bufnr, pred, metadata)
          local id = pred[2]
          local node = first(match[id])
          if not node then return end
          local text = vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[id] }) or ''
          if not metadata[id] then metadata[id] = {} end
          metadata[id].text = text:lower()
        end, force)
      end
    end,
  },
}
