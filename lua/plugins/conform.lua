return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        markdown = { "prettier" },
        yaml = { "prettier" },
        json = { "prettier" },
      },
      -- Format on save only for these filetypes (not Java — jdtls handles that)
      format_on_save = function(bufnr)
        local ft = vim.bo[bufnr].filetype
        local auto_format_fts = { yaml = true, json = true }
        if not auto_format_fts[ft] then return end
        return { timeout_ms = 2000, lsp_format = "fallback" }
      end,
    },
  },
}
