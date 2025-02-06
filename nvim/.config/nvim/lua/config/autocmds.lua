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
vim.api.nvim_create_autocmd({ "BufEnter", "InsertEnter" }, {
  group = "RelativeLineNumbers",
  pattern = "*",
  callback = function()
    vim.opt.relativenumber = false
  end,
  -- callback = unset_relative_number,
})

vim.api.nvim_create_autocmd({ "BufLeave", "InsertLeave" }, {
  group = "RelativeLineNumbers",
  pattern = "*",
  callback = function()
    vim.opt.relativenumber = true
  end,
  -- callback = set_relative_number,
})
