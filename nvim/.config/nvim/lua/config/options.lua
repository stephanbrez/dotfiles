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

local function setup_ssh_osc52_yank_sync()
  local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
  if not ok then
    return
  end

  -- Keep y/p using Neovim's normal unnamed register.
  vim.opt.clipboard = ""

  -- Use OSC 52 only for copying to the local machine clipboard.
  -- Do not allow paste/query from the terminal clipboard.
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = osc52.copy("+"),
      ["*"] = osc52.copy("*"),
    },
    paste = {
      ["+"] = function()
        return { "", "v" }
      end,
      ["*"] = function()
        return { "", "v" }
      end,
    },
  }

  -- Reload clipboard provider if it was already initialized.
  vim.g.loaded_clipboard_provider = nil

  -- Mirror every yank to the local system clipboard via OSC 52,
  -- while preserving normal Neovim register behavior.
  local group = vim.api.nvim_create_augroup("SSHOSC52YankSync", { clear = true })

  vim.api.nvim_create_autocmd("TextYankPost", {
    group = group,
    callback = function()
      local ev = vim.v.event
      if ev.operator ~= "y" then
        return
      end

      vim.fn.setreg("+", ev.regcontents, ev.regtype)
    end,
  })
end

if is_ssh then
  setup_ssh_osc52_yank_sync()
else
  -- Local machine: use system clipboard as default.
  vim.opt.clipboard = "unnamedplus"
end
