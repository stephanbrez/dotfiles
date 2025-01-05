return {
  -- disable conflicting with luasnip
  {
    "L3MON4D3/LuaSnip",
    keys = {
      { "<tab>", mode = { "i" }, false },
    },
  },
  -- custom key_bindings
  {
    "Exafunction/codeium.nvim",
    cmd = "Codeium",
    event = "InsertEnter",
    build = ":Codeium Auth",
    opts = {
      enable_cmp_source = vim.g.ai_cmp,
      virtual_text = {
        enabled = not vim.g.ai_cmp,
        key_bindings = {
          accept_word = "<M-h>",
          accept_line = "<M-l>",
          next = "<M-]>",
          prev = "<M-[>",
        },
      },
    },
  },
}
