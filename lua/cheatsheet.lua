-- Simple floating window cheatsheet for common keymaps
-- Code in English, UI text concise.

local M = {}

local function build_lines()
  return {
    "Cheatsheet — Common shortcuts",
    "",
    "Save/Quit:",
    "  <leader>ww  Save (Java formats first)",
    "  <leader>wq  Save modified and quit all (Java formats first)",
    "  <leader>x   Save current (if modified) and close window",
    "  <leader>qq  Quit current without saving",
    "  <leader>qa  Quit all without saving",
    "",
    "Search (Telescope):",
    "  <leader>ff  Find files",
    "  <leader>fg  Live grep (literal)",
    "  <leader>fG  Live grep (regex)",
    "",
    "Diagnostics:",
    "  <leader>d   Show diagnostic under cursor",
    "  [d / ]d     Prev/Next diagnostic",
    "  <leader>ld  Send diagnostics to Location List",
    "  <leader>lo  Open Location List",
    "  <leader>lc  Close Location List",
    "",
    "LSP (code actions):",
    "  <leader>ca  Code Action",
    "  <leader>rn  Rename",
    "  gd / gi / gr  Def / Impl / Refs",
    "  K           Hover",
    "  <leader>D   Type definition",
    "  Java: <leader>ji organize imports; <leader>jv/jc/jm extract var/const/method",
    "",
    "Harpoon:",
    "  <leader>a   Add file",
    "  <C-e>       Toggle menu",
    "  <leader>1..4 Jump to slot",
    "  <C-S-P>/<C-S-N> Prev/Next",
    "",
    "NvimTree:",
    "  <leader>e   Toggle tree",
    "  <leader>tw  Auto-fit tree width",
    "  o / v / s   Open / Vertical split / Horizontal split",
    "",
    "Windows (splits):",
    "  Ctrl-w v / s  Vertical / Horizontal split",
    "  Ctrl-h/j/k/l  Move between windows",
    "  Ctrl-w =      Equalize sizes",
    "",
    "Tests (Maven):",
    "  <leader>tt  mvn test (all)",
    "  <leader>tc  mvn -Dtest=<current class> test",
    "  <leader>tm  mvn -Dtest=<current class>#<method> test",
    "  <leader>tv  mvn verify",
    "  <leader>tr  repeat last test",
    "  <leader>tq  close test terminal",
  }
end

local function border_chars()
  return { "┌", "─", "┐", "│", "┘", "─", "└", "│" }
end

function M.show()
  local lines = build_lines()
  local maxw = 0
  for _, l in ipairs(lines) do
    if #l > maxw then maxw = #l end
  end
  local width = math.min(math.max(50, maxw + 2), math.floor(vim.o.columns * 0.9))
  local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.8))
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].filetype = 'cheatsheet'

  -- Pad lines to width-2 so border looks clean
  local padded = {}
  for _, l in ipairs(lines) do
    table.insert(padded, l)
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, padded)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    style = 'minimal',
    border = border_chars(),
  })

  -- Keymaps to close
  local opts = { buffer = buf, nowait = true, silent = true }
  vim.keymap.set('n', 'q', function() pcall(vim.api.nvim_win_close, win, true) end, opts)
  vim.keymap.set('n', '<Esc>', function() pcall(vim.api.nvim_win_close, win, true) end, opts)

  -- Prevent edits
  vim.bo[buf].modifiable = false
end

return M

