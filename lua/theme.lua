-- Everforest theme configuration
vim.g.everforest_background = "hard"
vim.g.everforest_enable_italic = 1
vim.opt.background = "dark"
vim.cmd.colorscheme("everforest")

-- Custom highlight overrides
vim.api.nvim_set_hl(0, "Comment", { fg = "#d7af5f", italic = true })
vim.api.nvim_set_hl(0, "Keyword", { fg = "#ffaf00", bold = true })
vim.api.nvim_set_hl(0, "String",  { fg = "#87af5f" })
vim.api.nvim_set_hl(0, "Function", { fg = "#ff8787" })

-- Define diagnostic signs after colorscheme is loaded
vim.fn.sign_define("NvimTreeDiagnosticErrorIcon", {text = "", texthl = "DiagnosticError"})
vim.fn.sign_define("NvimTreeDiagnosticWarnIcon", {text = "", texthl = "DiagnosticWarn"})
vim.fn.sign_define("NvimTreeDiagnosticInfoIcon", {text = "", texthl = "DiagnosticInfo"})
vim.fn.sign_define("NvimTreeDiagnosticHintIcon", {text = "", texthl = "DiagnosticHint"})

