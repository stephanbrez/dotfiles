-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Enable formatting concealment to hide markdown code
vim.opt.conceallevel = 2
-- vim.go.bg = "light"
--
--
-- vim.opt.listchars = { tab = "  ", trail = "·", eol = "↵" }
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Soft wrap text at window edge
vim.opt.textwidth = 80
vim.opt.wrapmargin = 0
vim.opt.wrap = true
-- Break lines at word
vim.opt.linebreak = true
-- Better wrapping
vim.opt.breakindent = true

-- make backspace behave in a sane manner
vim.opt.backspace = "indent,eol,start"

-- tabs
-- vim.opt.expandtab = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- completions
-- vim.g.ai_cmp = false
--
-- Scroll lines above and below
vim.opt.scrolloff = 8

-- Snacks
vim.g.lazyvim_picker = "snacks"

-- Make clipboard work over SSH
local is_ssh = vim.env.SSH_CONNECTION ~= nil or vim.env.SSH_TTY ~= nil

if is_ssh then
  -- Keep normal Neovim behavior over SSH:
  --   y -> unnamed register
  --   p -> unnamed register
  vim.opt.clipboard = ""

  local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
  if ok then
    local copy_osc52 = osc52.copy("+")

    vim.api.nvim_create_autocmd("TextYankPost", {
      group = vim.api.nvim_create_augroup("SSHOSC52YankSync", { clear = true }),
      callback = function()
        local ev = vim.v.event

        -- Only mirror real yanks from the unnamed register.
        -- This avoids double-copying explicit "+y or "*y operations.
        if ev.operator ~= "y" or ev.regname ~= "" then
          return
        end

        -- Send the yanked text to the local machine clipboard via OSC 52.
        -- ev.regcontents is a list of lines; ev.regtype preserves the yank type.
        copy_osc52(ev.regcontents, ev.regtype)
      end,
    })
  end
else
  -- Local machine: use system clipboard normally.
  vim.opt.clipboard = "unnamedplus"
end
