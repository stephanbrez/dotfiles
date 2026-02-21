-- https://github.com/MeanderingProgrammer/render-markdown.nvim
return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    -- dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      latex = {
        enabled = true,
      },
      code = {
        sign = true,
      },
      heading = {
        -- Turn on / off any sign column related rendering
        sign = true,
        -- Replaces '#+' of 'atx_h._marker'
        -- The number of '#' in the heading determines the 'level'
        -- The 'level' is used to index into the list using a cycle
        -- If the value is a function the input context contains the nesting level of the heading within sections
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        -- Determines how icons fill the available space:
        --  right:   '#'s are concealed and icon is appended to right side
        --  inline:  '#'s are concealed and icon is inlined on left side
        --  overlay: icon is left padded with spaces and inserted on left hiding any additional '#'
        position = "overlay",
        -- Added to the sign column if enabled
        -- The 'level' is used to index into the list using a cycle
        signs = { "󰫎 " },
        -- Width of the heading background:
        --  block: width of the heading text
        --  full:  full width of the window
        -- Can also be a list of the above values in which case the 'level' is used
        -- to index into the list using a clamp},
      },
      checkbox = {
        enabled = true,
        -- unchecked = { icon = "󰄱 " },
        -- checked = { icon = "󰱒 " },
        -- optional:
        -- custom = { todo = { rendered = "◯ " } },
      },
    },
  },
}
