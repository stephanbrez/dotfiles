return {
  "chenxin-yan/footnote.nvim",
  ft = "markdown",
  config = function()
    require("footnote").setup({
      keys = {
        n = {
          new_footnote = "",
          organize_footnotes = "",
          next_footnote = "",
          prev_footnote = "",
        },
        i = {
          new_footnote = "",
        },
      },
    })
  end,
}
