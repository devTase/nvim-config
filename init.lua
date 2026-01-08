require('python_provider')

-- Disable Perl provider
vim.g.loaded_perl_provider = 0

-- Basic settings
vim.opt.number = true
vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true -- ensure truecolor
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50
vim.opt.colorcolumn = "120"
vim.opt.backupcopy = 'yes' -- safer writes when tools/watchers touch files

-- Prevent window creation issues
vim.opt.hidden = true -- Allow hidden buffers
vim.opt.switchbuf = 'useopen,usetab' -- Smarter buffer switching

-- Enable debug logging
vim.opt.verbose = 1

-- Debug autocommands para eventos de janela
local debug_group = vim.api.nvim_create_augroup('DebugWindowEvents', { clear = true })
vim.api.nvim_create_autocmd('WinEnter', {
  group = debug_group,
  callback = function()
    local win_info = vim.fn.winlayout()
    vim.notify("WinEnter - Layout: " .. vim.inspect(win_info), vim.log.levels.DEBUG)
    vim.notify("WinEnter - Total windows: " .. vim.fn.winnr('$'), vim.log.levels.DEBUG)
  end
})

vim.api.nvim_create_autocmd('BufEnter', {
  group = debug_group,
  callback = function()
    local buf_name = vim.api.nvim_buf_get_name(0)
    local win_count = vim.fn.winnr('$')
    vim.notify("BufEnter - Buffer: " .. buf_name .. ", Windows: " .. win_count, vim.log.levels.DEBUG)
  end
})

-- Set leader key
vim.g.mapleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin configuration
require("lazy").setup({
  { import = "plugins" },
})

-- Mason setup
require('mason').setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

require('mason-lspconfig').setup({
  ensure_installed = { 'clangd', 'lua_ls', 'pyright' },
})

-- Completion setup
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
    sources = 
      cmp.config.sources(
          {
              { name = 'nvim_lsp' },
              { name = 'luasnip' },
          }, 
            {
                { name = 'buffer' }})
})

-- Silence specific noisy LSP notifications (e.g., jdtls resolveMainClass during previews)
pcall(require, 'user.quiet_lsp')

-- Treesitter configuration
require('nvim-treesitter.configs').setup({
  ensure_installed = { "c", "cpp", "java", "lua", "python", "json", "vim", "vimdoc", "query" },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
})

-- Harpoon setup
local harpoon = require("harpoon")
harpoon:setup()

-- Harpoon keymaps
local keymap = vim.keymap.set
keymap("n", "<leader>a", function() harpoon:list():add() end, { desc = 'Harpoon add file' })
keymap("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = 'Harpoon menu' })

-- Navigate to specific files (using leader to avoid conflicts with tmux navigator)
keymap("n", "<leader>1", function() harpoon:list():select(1) end, { desc = 'Harpoon file 1' })
keymap("n", "<leader>2", function() harpoon:list():select(2) end, { desc = 'Harpoon file 2' })
keymap("n", "<leader>3", function() harpoon:list():select(3) end, { desc = 'Harpoon file 3' })
keymap("n", "<leader>4", function() harpoon:list():select(4) end, { desc = 'Harpoon file 4' })

-- Toggle previous & next buffers stored within Harpoon list
keymap("n", "<C-S-P>", function() harpoon:list():prev() end, { desc = 'Harpoon previous' })
keymap("n", "<C-S-N>", function() harpoon:list():next() end, { desc = 'Harpoon next' })


-- Gitsigns setup
require('gitsigns').setup()

-- Helpers
local function safe_java_format(bufnr)
  pcall(function()
    vim.lsp.buf.format({
      async = false,
      bufnr = bufnr,
      timeout_ms = 2000,
      filter = function(client) return client.name == "jdtls" end,
    })
  end)
end

local function is_normal_writable(bufnr)
  if not vim.api.nvim_buf_is_loaded(bufnr) then return false end
  if vim.bo[bufnr].buftype ~= '' then return false end
  if vim.bo[bufnr].readonly then return false end
  local name = vim.api.nvim_buf_get_name(bufnr)
  if not name or name == '' then return false end
  return true
end

-- Maven test helpers
local last_test_cmd = nil
local last_test_win = nil

local function project_root()
  local cwd = vim.fn.getcwd()
  local res = vim.fn.systemlist({ 'git', 'rev-parse', '--show-toplevel' })
  if vim.v.shell_error == 0 and #res > 0 and res[1] ~= '' then
    return res[1]
  end
  return cwd
end

local function run_mvn(args)
  local root = project_root()
  -- open a bottom split terminal and run the command in project root
  vim.cmd('botright split')
  vim.cmd('resize 15')
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(win, buf)
  -- Verbose Maven output with colors; enable dynamic agent loading to hide ByteBuddy warning
  local cmd = 'MAVEN_OPTS="-XX:+EnableDynamicAgentLoading" mvn -Dstyle.color=always -DtrimStackTrace=false ' .. args
  last_test_cmd = cmd
  last_test_win = win
  vim.fn.termopen({ 'bash', '-lc', cmd }, { cwd = root })
  vim.cmd('startinsert')
end

local function current_test_class()
  return vim.fn.expand('%:t:r')
end

local function current_test_method()
  local cursor = vim.api.nvim_win_get_cursor(0)[1]
  for lnum = cursor, math.max(1, cursor - 200), -1 do
    local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1] or ''
    -- common JUnit method patterns
    local name = line:match('void%s+([%w_]+)%s*%(')
    if not name then
      name = line:match('public%s+[%w_<>%[%]]+%s+([%w_]+)%s*%(')
    end
    if not name then
      name = line:match('([%w_]+)%s*%(')
      if name and (name == 'if' or name == 'for' or name == 'while' or name == 'switch' or name == 'catch' or name == 'return') then
        name = nil
      end
    end
    if name then return name end
  end
  return nil
end

-- Key mappings
local keymap = vim.keymap.set

-- File explorer
keymap('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle file explorer' })

-- File finding with fzf-lua (estável e sem erros de espaço)
keymap('n', '<leader>ff', function()
  vim.cmd('NvimTreeClose')
  require('fzf-lua').files()
end, { desc = 'Find files (fzf-lua)' })

-- Maven tests
keymap('n', '<leader>tt', function()
  run_mvn('test')
end, { desc = 'Maven: test all' })

keymap('n', '<leader>tc', function()
  local cls = current_test_class()
  if cls == nil or cls == '' then
    vim.notify('Cannot detect test class from filename', vim.log.levels.WARN)
    return
  end
  run_mvn('-Dtest=' .. cls .. ' test')
end, { desc = 'Maven: test current class' })

keymap('n', '<leader>tm', function()
  local cls = current_test_class()
  local m = current_test_method()
  if not cls or cls == '' then
    vim.notify('Cannot detect test class from filename', vim.log.levels.WARN)
    return
  end
  if not m or m == '' then
    vim.notify('Cannot detect test method under cursor', vim.log.levels.WARN)
    return
  end
  run_mvn('-Dtest=' .. cls .. '#' .. m .. ' test')
end, { desc = 'Maven: test method under cursor' })

keymap('n', '<leader>tv', function()
  run_mvn('verify')
end, { desc = 'Maven: verify (unit+integration)' })

-- Repeat last test command
keymap('n', '<leader>tr', function()
  if not last_test_cmd or last_test_cmd == '' then
    vim.notify('No previous test command to repeat', vim.log.levels.INFO)
    return
  end
  -- Re-run using the exact last command string
  local root = project_root()
  vim.cmd('botright split')
  vim.cmd('resize 15')
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(win, buf)
  last_test_win = win
  vim.fn.termopen({ 'bash', '-lc', last_test_cmd }, { cwd = root })
  vim.cmd('startinsert')
end, { desc = 'Maven: repeat last test' })

-- Quit last test terminal
keymap('n', '<leader>tq', function()
  if last_test_win and vim.api.nvim_win_is_valid(last_test_win) then
    pcall(vim.api.nvim_win_close, last_test_win, true)
    last_test_win = nil
  else
    -- Try to close current window if it is a terminal
    local bt = vim.bo.buftype
    if bt == 'terminal' then
      pcall(vim.cmd, 'q')
    else
      vim.notify('No test terminal to close', vim.log.levels.INFO)
    end
  end
end, { desc = 'Maven: close test terminal' })
keymap('n', '<leader>fg', function()
  vim.cmd('NvimTreeClose')
  require('fzf-lua').live_grep({
    rg_opts = "--column --line-number --no-heading --color=always --smart-case --fixed-strings --max-columns=4096 --hidden --glob '!{.git,node_modules}'"
  })
end, { desc = 'Live grep (literal)' })
keymap('n', '<leader>fb', function()
  vim.cmd('NvimTreeClose')
  require('fzf-lua').buffers()
end, { desc = 'Find buffers' })
keymap('n', '<leader>fG', function()
  vim.cmd('NvimTreeClose')
  require('fzf-lua').live_grep()
end, { desc = 'Live grep (regex)' })
keymap('n', '<leader>fh', function()
  vim.cmd('NvimTreeClose')
  require('fzf-lua').help_tags()
end, { desc = 'Help tags' })

-- Cheatsheet
vim.api.nvim_create_user_command('Cheatsheet', function() require('cheatsheet').show() end, {})
keymap('n', '<leader>?', function() require('cheatsheet').show() end, { desc = 'Show cheatsheet' })

-- LSP
keymap('n', 'gd', function()
  local function supports(m)
    for _, c in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
      if c.supports_method and c:supports_method(m) then return true end
    end
    return false
  end
  if not supports('textDocument/definition') and vim.bo.filetype == 'java' then
    pcall(function() require('user.jdtls_util').ensure_started() end)
  end
  if supports('textDocument/definition') then
    vim.cmd('NvimTreeClose')
    require('fzf-lua').lsp_definitions()
  else
    vim.notify('No LSP with definitions for this buffer', vim.log.levels.INFO)
  end
end, { desc = 'Definition (fzf-lua)' })
keymap('n', 'K', vim.lsp.buf.hover, { desc = 'Hover documentation' })
keymap('n', 'gi', function()
  local function supports(m)
    for _, c in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
      if c.supports_method and c:supports_method(m) then return true end
    end
    return false
  end
  if not supports('textDocument/implementation') and vim.bo.filetype == 'java' then
    pcall(function() require('user.jdtls_util').ensure_started() end)
  end
  if supports('textDocument/implementation') then
    vim.cmd('NvimTreeClose')
    require('fzf-lua').lsp_implementations()
  else
    vim.notify('No LSP with implementations for this buffer', vim.log.levels.INFO)
  end
end, { desc = 'Implementation (fzf-lua)' })
keymap('n', '<C-k>', vim.lsp.buf.signature_help, { desc = 'Signature help' })
keymap('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, { desc = 'Add workspace folder' })
keymap('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, { desc = 'Remove workspace folder' })
keymap('n', '<leader>wl', function()
  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, { desc = 'List workspace folders' })
keymap('n', '<leader>D', function() require('lsp.handlers').goto_type_definition() end, { desc = 'Type definition (smart)' })
keymap('n', 'gt', function()
  local function supports(m)
    for _, c in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
      if c.supports_method and c:supports_method(m) then return true end
    end
    return false
  end
  if not supports('textDocument/typeDefinition') and vim.bo.filetype == 'java' then
    pcall(function() require('user.jdtls_util').ensure_started() end)
  end
  if supports('textDocument/typeDefinition') then
    vim.cmd('NvimTreeClose')
    require('fzf-lua').lsp_type_definitions()
  else
    vim.notify('No LSP with typeDefinition for this buffer', vim.log.levels.INFO)
  end
end, { desc = 'Type definition (fzf-lua)' })
keymap('n', 'gD', function() require('lsp.handlers').goto_declaration() end, { desc = 'Go to declaration (smart)' })
keymap('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename' })
keymap('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action' })
keymap('n', 'gr', function()
  local function supports(m)
    for _, c in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
      if c.supports_method and c:supports_method(m) then return true end
    end
    return false
  end
  if not supports('textDocument/references') and vim.bo.filetype == 'java' then
    pcall(function() require('user.jdtls_util').ensure_started() end)
  end
  if supports('textDocument/references') then
    vim.cmd('NvimTreeClose')
    require('fzf-lua').lsp_references()
  else
    vim.notify('No LSP with references for this buffer', vim.log.levels.INFO)
  end
end, { desc = 'References (fzf-lua)' })
keymap('n', '<leader>f', function()
  vim.lsp.buf.format { async = true }
end, { desc = 'Format' })

-- Diagnostics
keymap('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Open diagnostic float' })
keymap('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic' })
keymap('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic' })
keymap('n', '<leader>ld', vim.diagnostic.setloclist, { desc = 'Diagnostics: set location list' })
keymap('n', '<leader>lo', ':lopen<CR>', { desc = 'Diagnostics: open location list' })
keymap('n', '<leader>lc', ':lclose<CR>', { desc = 'Diagnostics: close location list' })

-- General

-- Save (preferred): <leader>ww
keymap('n', '<leader>ww', function()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].filetype == 'java' then
    safe_java_format(bufnr)
  end
  -- Force write (!), only for normal file buffers with a filename
  if vim.bo[bufnr].buftype == '' then
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name and name ~= '' then
      local ok, err = pcall(function()
        vim.cmd('silent keepalt keepjumps noautocmd write!')
      end)
      if not ok then
        vim.notify('Save (!w) failed: ' .. tostring(err), vim.log.levels.WARN)
      end
    else
      vim.notify('No filename; cannot perform write!.', vim.log.levels.INFO)
    end
  else
    vim.notify('Not a normal file buffer; skipping write!.', vim.log.levels.INFO)
  end
end, { desc = 'Save file (!) (Java formats first)' })

keymap('n', '<leader>q', ':q<CR>', { desc = 'Quit' })
-- Quit current without saving: <leader>qq
keymap('n', '<leader>qq', ':q!<CR>', { desc = 'Quit without saving' })
keymap('n', '<leader>x', function()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].filetype == 'java' then
    safe_java_format(bufnr)
  end
  if is_normal_writable(bufnr) and vim.bo[bufnr].modified then
    pcall(function()
      vim.cmd('silent keepalt keepjumps noautocmd update')
    end)
  end
  vim.cmd('q')
end, { desc = 'Save (if modified) and quit (Java formats first)' })
keymap('n', '<leader>qa', ':qa!<CR>', { desc = 'Quit all without saving' })
keymap('n', '<leader>wq', function()
  -- 1) Format all loaded Java buffers safely
  local bufs = vim.api.nvim_list_bufs()
  for _, bufnr in ipairs(bufs) do
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].filetype == 'java' then
      safe_java_format(bufnr)
    end
  end

  -- 2) Write only normal, writable, modified file-buffers to avoid E13 on special buffers
  for _, bufnr in ipairs(bufs) do
    if is_normal_writable(bufnr) and vim.bo[bufnr].modified then
      pcall(function()
        vim.api.nvim_buf_call(bufnr, function()
          vim.cmd('silent keepalt keepjumps noautocmd update')
        end)
      end)
    end
  end

  -- 3) Quit all
  vim.cmd('qa')
end, { desc = 'Save all and quit (Java: format all, write modified, then quit)' })

-- Window navigation (handled by vim-tmux-navigator)
-- keymap('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
-- keymap('n', '<C-j>', '<C-w>j', { desc = 'Move to down window' })
-- keymap('n', '<C-k>', '<C-w>k', { desc = 'Move to up window' })
-- keymap('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- Buffer navigation
keymap('n', '<leader>bn', ':bnext<CR>', { desc = 'Next buffer' })
keymap('n', '<leader>bp', ':bprev<CR>', { desc = 'Previous buffer' })
keymap('n', '<leader>bd', ':bdelete<CR>', { desc = 'Delete buffer' })

-- Clear search highlighting
keymap('n', '<leader>h', ':nohlsearch<CR>', { desc = 'Clear search highlighting' })

-- Java specific autocommands
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    -- Set Java-specific options
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.expandtab = true
    
    -- Java-specific key mappings
    vim.keymap.set('n', '<leader>jv', ':lua require("jdtls").extract_variable()<CR>', { desc = 'Extract variable', buffer = true })
    vim.keymap.set('v', '<leader>jv', '<Esc><Cmd>lua require("jdtls").extract_variable(true)<CR>', { desc = 'Extract variable', buffer = true })
    vim.keymap.set('n', '<leader>jc', ':lua require("jdtls").extract_constant()<CR>', { desc = 'Extract constant', buffer = true })
    vim.keymap.set('v', '<leader>jc', '<Esc><Cmd>lua require("jdtls").extract_constant(true)<CR>', { desc = 'Extract constant', buffer = true })
    vim.keymap.set('v', '<leader>jm', '<Esc><Cmd>lua require("jdtls").extract_method(true)<CR>', { desc = 'Extract method', buffer = true })
  end,
})
vim.o.termguicolors = true

