return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    -- Recommended for `ask()` and `select()`.
    -- Required for `snacks` provider.
    ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      provider = {
        enabled = "wezterm",
        wezterm = {
          -- ...
        },
      },
    }
    -- Required for `opts.events.reload`.
    vim.o.autoread = true

    -- Recommended/example keymaps.
    vim.keymap.set({ "n", "x" }, "<leader>oa", function()
      require("opencode").ask("@this: ", { submit = true })
    end, { desc = "Ask opencode" })
    vim.keymap.set({ "n", "x" }, "<leader>ox", function()
      require("opencode").select()
    end, { desc = "Execute opencode action…" })
    vim.keymap.set({ "n", "t" }, "<leader>o.", function()
      require("opencode").toggle()
    end, { desc = "Toggle opencode" })
    vim.keymap.set("n", "<leader>ou", function()
      require("opencode").command("session.half.page.up")
    end, { desc = "opencode half page up" })
    vim.keymap.set("n", "<leader>od", function()
      require("opencode").command("session.half.page.down")
    end, { desc = "opencode half page down" })
    vim.keymap.set({ "n", "x" }, "<leader>os", function()
      require("opencode").select()
    end, { desc = "Select prompt" })
    --
    -- Visual mode
    -- vim.keymap.set({ "v" }, "<leader>oA", function()
    --   require("opencode").ask("@this: ", { submit = true })
    -- end, { desc = "Ask opencode" })
    -- vim.keymap.set({ "v" }, "<leader>oX", function()
    --   require("opencode").select()
    -- end, { desc = "Execute opencode action…" })

    -- Normal mode
    vim.keymap.set({ "n", "x" }, "go", function()
      return require("opencode").operator("@this ")
    end, { expr = true, desc = "Add range to opencode" })
    vim.keymap.set("n", "goo", function()
      return require("opencode").operator("@this ") .. "_"
    end, { expr = true, desc = "Add line to opencode" })

    -- Prompts
    vim.keymap.set({ "n", "x" }, "<leader>of", function()
      require("opencode").prompt("fix", { submit = true })
    end, { desc = "Fix this..." }) --
    vim.keymap.set({ "n", "x" }, "<leader>oe", function()
      require("opencode").prompt("explain", { submit = true })
    end, { desc = "Explain this..." }) --
    vim.keymap.set({ "n", "x" }, "<leader>or", function()
      require("opencode").prompt("review", { submit = true })
    end, { desc = "Review this..." }) --
    vim.keymap.set({ "n", "x" }, "<leader>oo", function()
      require("opencode").prompt("optimize", { submit = true })
    end, { desc = "Optimize this..." }) --
    vim.keymap.set({ "n", "x" }, "<leader>oi", function()
      require("opencode").prompt("implement", { submit = true })
    end, { desc = "Implement this..." }) --

    -- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o".
    -- vim.keymap.set("n", "+", "<C-a>", { desc = "Increment", noremap = true })
    -- vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement", noremap = true })
  end,
}
