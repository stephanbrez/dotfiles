-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- Toggle line numbers from relative to absolute based on insert mode
-- Normal Mode = relative
-- Define the autocommand group
vim.api.nvim_create_augroup("RelativeLineNumbers", { clear = true })

-- Create autocommands to toggle relative line numbers
-- Disable relative line numbers when entering insert mode or switching away
-- from a buffer
vim.api.nvim_create_autocmd({ "BufLeave", "InsertEnter" }, {
  group = "RelativeLineNumbers",
  pattern = "*",
  callback = function()
    vim.opt.relativenumber = false
  end,
  -- callback = unset_relative_number,
})
-- Enable relative line numbers when leaving insert mode or switching to a
-- buffer
vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
  group = "RelativeLineNumbers",
  pattern = "*",
  callback = function()
    vim.opt.relativenumber = true
  end,
  -- callback = set_relative_number,
})

-- Set up keymaps for markdown files only
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.keymap.set(
      "n",
      "<leader>Fn",
      "<cmd>lua require('footnote').new_footnote()<cr>",
      { buffer = 0, silent = true, desc = "Create markdown footnote" }
    )
    vim.keymap.set(
      "i",
      "<C-f>",
      "<cmd>lua require('footnote').new_footnote()<cr>",
      { buffer = 0, silent = true, desc = "Create markdown footnote" }
    )
    vim.keymap.set(
      "n",
      "<leader>Fo",
      "<cmd>lua require('footnote').organize_footnotes()<cr>",
      { buffer = 0, silent = true, desc = "Organize footnotes" }
    )
    vim.keymap.set(
      "n",
      "]f",
      "<cmd>lua require('footnote').next_footnote()<cr>",
      { buffer = 0, silent = true, desc = "Next footnote" }
    )
    vim.keymap.set(
      "n",
      "[f",
      "<cmd>lua require('footnote').prev_footnote()<cr>",
      { buffer = 0, silent = true, desc = "Previous footnote" }
    )
  end,
})
