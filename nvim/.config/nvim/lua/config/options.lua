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

local function env_has(name)
  local value = vim.env[name]
  return value ~= nil and value ~= ""
end

local function is_truthy(value)
  if not value then
    return false
  end
  value = value:lower()
  return value == "1" or value == "true" or value == "yes" or value == "on" or value == "force"
end

local function is_falsy(value)
  if not value then
    return false
  end
  value = value:lower()
  return value == "0" or value == "false" or value == "no" or value == "off"
end

local function clipboard_env_state()
  local wezterm_executable = vim.env.WEZTERM_EXECUTABLE or ""
  local mode = vim.env.NVIM_OSC52_WRITEONLY
  local has_mux_server = wezterm_executable:find("wezterm-mux-server", 1, true) ~= nil
  local has_ssh_markers = env_has("SSH_TTY") or env_has("SSH_CONNECTION") or env_has("SSH_CLIENT")

  return {
    mode = mode,
    force_on = is_truthy(mode),
    force_off = is_falsy(mode),
    has_mux_server = has_mux_server,
    has_ssh_markers = has_ssh_markers,
    is_remote = has_mux_server or has_ssh_markers,
    wezterm_executable = wezterm_executable,
  }
end

local clipboard_state = clipboard_env_state()
local use_osc52_writeonly = not clipboard_state.force_off
  and (clipboard_state.force_on or clipboard_state.is_remote)

if use_osc52_writeonly then
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

vim.api.nvim_create_user_command("ClipboardDebug", function()
  local state = clipboard_env_state()
  state.loaded_clipboard_provider = vim.g.loaded_clipboard_provider
  state.clipboard_option = vim.o.clipboard
  state.term_program = vim.env.TERM_PROGRAM
  state.provider = vim.fn["provider#clipboard#Executable"]()
  state.active_provider_name = type(vim.g.clipboard) == "table" and vim.g.clipboard.name or vim.g.clipboard
  print(vim.inspect(state))
end, { desc = "Inspect clipboard provider selection" })

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
