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

-- Asymmetric clipboard: yank -> nvim unnamed + system; paste -> nvim unnamed only.
-- Use "+y / "+p explicitly when you actually want the system clipboard both ways.
vim.opt.clipboard = ""

local is_ssh = vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil
if is_ssh then
  local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
  if ok then
    vim.g.clipboard = {
      name = "osc52-writeonly",
      copy = {
        ["+"] = osc52.copy("+"),
        ["*"] = osc52.copy("*"),
      },
      paste = {
        ["+"] = function() return { {}, "" } end,
        ["*"] = function() return { {}, "" } end,
      },
    }
  end
end

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("MirrorYankToSystem", { clear = true }),
  callback = function()
    local ev = vim.v.event
    if ev.operator ~= "y" or ev.regname ~= "" then
      return
    end
    vim.fn.setreg("+", ev.regcontents, ev.regtype)
  end,
})
