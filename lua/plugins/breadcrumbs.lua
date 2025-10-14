return {
  "Bekaboo/dropbar.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    bar = {
      enable = function(buf, win)
        local bt = vim.bo[buf].buftype
        local ft = vim.bo[buf].filetype
        if bt == "terminal" then return false end
        local disabled = {
          "NvimTree", "neo-tree", "aerial", "alpha", "dashboard",
          "dapui_scopes", "dapui_breakpoints", "dapui_stacks",
          "help", "lazy", "mason", "trouble", "toggleterm", "Outline",
        }
        for _, d in ipairs(disabled) do
          if ft == d then return false end
        end
        return true
      end,
    },
    icons = {
      ui = {
        bar = { separator = "  ", extends = "…" },
      },
      kinds = {
        File = "", Module = "", Namespace = "", Package = "",
        Class = "", Method = "", Property = "", Field = "",
        Constructor = "", Enum = "", Interface = "", Function = "",
        Variable = "", Constant = "", String = "", Number = "",
        Boolean = "", Array = "", Object = "", Key = "",
        Null = "ﳠ", EnumMember = "", Struct = "פּ", Event = "",
        Operator = "", TypeParameter = "",
      },
    },
  },
}
