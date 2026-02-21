return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.sections.lualine_z = {
        { require("opencode").statusline },
      }
      -- table.insert(opts.sections.lualine_x, "😄")
    end,
  },
}
