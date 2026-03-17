return {
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
    keys = {
      { "<leader>xt", "<cmd>Trouble todo toggle<CR>", desc = "TODOs (Trouble)" },
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous TODO comment" },
    },
  },
}
