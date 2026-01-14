return {
  "saghen/blink.cmp",
  dependencies = {
    { "saghen/blink.compat", lazy = true, version = false },
  },
  opts = {
    sources = {
      -- LazyVim as custom option compat to pass in external sources with blink.compat
      compat = { "obsidian", "obsidian_new", "obsidian_tags" },
      default = {
        "avante_commands",
        "avante_mentions",
        "avante_shortcuts",
        "avante_files",
      },
      providers = {
        avante_commands = {
          name = "avante_commands",
          module = "blink.compat.source",
          score_offset = 90, -- show at a higher priority than lsp
          opts = {},
        },
        avante_files = {
          name = "avante_files",
          module = "blink.compat.source",
          score_offset = 100, -- show at a higher priority than lsp
          opts = {},
        },
        avante_mentions = {
          name = "avante_mentions",
          module = "blink.compat.source",
          score_offset = 1000, -- show at a higher priority than lsp
          opts = {},
        },
        avante_shortcuts = {
          name = "avante_shortcuts",
          module = "blink.compat.source",
          score_offset = 1000, -- show at a higher priority than lsp
          opts = {},
        },
      },
    },
    keymap = {
      preset = "super-tab",
      ["<C-y>"] = { "select_and_accept" },
    },
  },
}
