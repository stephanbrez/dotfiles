return {
  -- add gruvbox
  { "ellisonleao/gruvbox.nvim" },
  -- { "rose-pine/neovim", name = "rose-pine", dark_variant = "moon" },
  { "sainnhe/gruvbox-material" },

  -- set LazyVim theme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox-material",
    },
  },
  -- add auto-dark-mode
  {
    "f-person/auto-dark-mode.nvim",
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        vim.api.nvim_set_option("background", "dark")
        vim.cmd("colorscheme gruvbox-material")
      end,
      set_light_mode = function()
        vim.api.nvim_set_option("background", "light")
        vim.cmd("colorscheme gruvbox")
      end,
    },
  },
}
