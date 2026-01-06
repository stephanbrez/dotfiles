return {
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {},
      spec = {
        {
          { "<leader>z", group = "zen-mode", icon = { icon = " ", color = "grey" } },
          { "<leader>m", group = "markdown", mode = { "n", "v" }, icon = { icon = " ", color = "red" } },
          { "<leader>mh", group = "headings", mode = { "n", "v" }, icon = { icon = " ", color = "red" } },
          { "<leader>O", group = "obsidian", mode = { "n", "v" }, icon = { icon = "󰂺 ", color = "blue" } },
        },
      },
    },
  },
}
