return {
  "saghen/blink.cmp",
  dependencies = {
    { "saghen/blink.compat", lazy = true, version = false },
  },
  opts = {
    sources = {
      -- LazyVim as custom option compat to pass in external sources with blink.compat
      compat = { "obsidian", "obsidian_new", "obsidian_tags" },
    },
    keymap = {
      preset = "super-tab",
      ["<C-y>"] = { "select_and_accept" },
    },
  },
}
