return {
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      if LazyVim.has("zen-mode.nvim") then
        opts.defaults["<leader>z"] = { name = "+zen-mode" }
      end
      if LazyVim.has("obsidian.nvim") then
        opts.defaults["<leader>o"] = { name = "+obsidian" }
      end
      opts.defaults["<leader>m"] = { name = "+markdown" }
    end,
  },
}
