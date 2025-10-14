local orig = vim.notify
vim.notify = function(msg, level, opts)
  if type(msg) == 'string' then
    if msg:find('vscode%.java%.resolveMainClass', 1, true) then
      return
    end
  end
  return orig(msg, level, opts)
end