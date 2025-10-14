return {
  "lukas-reineke/headlines.nvim",
  ft = { "markdown" },
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {
    markdown = {
      headline_highlights = { "Headline1","Headline2","Headline3","Headline4","Headline5","Headline6" },
      dash_highlight = "Dash",
      quote_highlight = "Quote",
      bullets = { "", "", "", "" },
    },
  },
  config = function(_, opts)
    require("headlines").setup(opts)
    -- Soft highlights matching Everforest palette
    vim.api.nvim_set_hl(0, "Headline1", { fg = "#a7c080", bold = true })
    vim.api.nvim_set_hl(0, "Headline2", { fg = "#83c092", bold = true })
    vim.api.nvim_set_hl(0, "Headline3", { fg = "#7fbbb3", bold = true })
    vim.api.nvim_set_hl(0, "Headline4", { fg = "#dbbc7f", bold = true })
    vim.api.nvim_set_hl(0, "Headline5", { fg = "#e69875", bold = true })
    vim.api.nvim_set_hl(0, "Headline6", { fg = "#d699b6", bold = true })
    vim.api.nvim_set_hl(0, "Dash", { fg = "#4b565c" })
    vim.api.nvim_set_hl(0, "Quote", { fg = "#859289", italic = true })
  end,
}
