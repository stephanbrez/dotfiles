return {
  -- add gruvbox
  -- { "ellisonleao/gruvbox.nvim" },
  {
    "zenbones-theme/zenbones.nvim",
    -- Optionally install Lush. Allows for more configuration or extending the colorscheme
    -- If you don't want to install lush, make sure to set g:zenbones_compat = 1
    -- In Vim, compat mode is turned on as Lush only works in Neovim.
    dependencies = "rktjmp/lush.nvim",
    lazy = false,
    priority = 1000,
    -- you can set set configuration options here
    config = function()
      --     vim.g.zenbones_darken_comments = 45
      vim.cmd.colorscheme("forestbones")
    end,
  },
  { "rose-pine/neovim", name = "rose-pine", dark_variant = "moon" },
  { "sainnhe/gruvbox-material" },
  -- {
  --   "sainnhe/everforest",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     -- Optionally configure and load the colorscheme
  --     -- directly inside the plugin declaration.
  --     vim.g.everforest_enable_italic = true
  --     vim.g.everforest_background = "hard"
  --     vim.cmd.colorscheme("everforest")
  --   end,
  -- },
  -- {
  --   "navarasu/onedark.nvim",
  --   priority = 1000, -- make sure to load this before all the other start plugins
  --   config = function()
  --     require("onedark").setup({
  --       style = "darker",
  --     })
  --     -- Enable theme
  --     -- require("onedark").load()
  --   end,
  -- },
  -- {
  --   "loctvl842/monokai-pro.nvim",
  --   priority = 1000, -- make sure to load this before all the other start plugins
  --   config = function()
  --     require("monokai-pro").setup()
  --   end,
  -- }, -- set LazyVim theme
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "monokai-pro-light",
    },
  },
  -- add auto-dark-mode
  -- {
  --   "f-person/auto-dark-mode.nvim",
  --   opts = {
  --     update_interval = 1000,
  --     set_dark_mode = function()
  --       vim.api.nvim_set_option("background", "dark")
  --       vim.cmd("colorscheme rose-pine")
  --     end,
  --     set_light_mode = function()
  --       vim.api.nvim_set_option("background", "light")
  --       vim.cmd("colorscheme rose-pine")
  --     end,
  --   },
  -- },
}
