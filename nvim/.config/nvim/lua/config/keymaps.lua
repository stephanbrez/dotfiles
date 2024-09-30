-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Navigation
-- ###################
-- vim.keymap.set("i", "<CR>", "<Esc>", { noremap = true, silent = true })

-- Center cursor after scroll
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Jump between markdown headers
vim.keymap.set("n", "gj", [[/^##\+ .*<CR>]], { buffer = true, silent = true })
vim.keymap.set("n", "gk", [[?^##\+ .*<CR>]], { buffer = true, silent = true })

-- Editing
-- ###################
-- Function to toggle <CR> mapping in insert mode
local function toggleEnterMapping()
  if vim.fn.empty(vim.fn.mapcheck("<CR>", "i")) == 1 then
    -- Map <CR> to <Esc>`^ and return "\<Esc>" so it acts like Esc
    vim.keymap.set("i", "<CR>", "<Esc>`^", { noremap = true })
    return vim.api.nvim_replace_termcodes("<Esc>", true, true, true)
  else
    -- Unmap <CR> and return "\<CR>" so it behaves as normal
    vim.keymap.del("i", "<CR>")
    return vim.api.nvim_replace_termcodes("<CR>", true, true, true)
  end
end

-- Call the function to toggle <CR> mapping initially
toggleEnterMapping()

-- Mapping for <C-CR> in insert mode to toggle <CR> mapping
vim.keymap.set("i", "<C-CR>", toggleEnterMapping, { silent = false, noremap = true, desc = "Toggle Enter Mapping" })
-- Optional mappings to ensure <CR> cancels prefix, selection, operator in other modes
vim.keymap.set("n", "<CR>", "<Esc>", { noremap = true })
vim.keymap.set("v", "<CR>", "<Esc>gV", { noremap = true })
vim.keymap.set("o", "<CR>", "<Esc>", { noremap = true })

-- Select all
vim.keymap.set("n", "==", "gg<S-v>G")

-- Disable x sending to default register
vim.keymap.set("n", "x", '"_x', { desc = "Delete character without copying to default register" })

-- Make Y behave like C or D
vim.keymap.set("n", "Y", "y$")

-- Make d and D go to vim register "a"
vim.keymap.set("n", "d", '"ad')
vim.keymap.set("v", "d", '"ad')
vim.keymap.set("n", "D", '"aD')
vim.keymap.set("v", "D", '"aD')

-- Make leader-x cut to clipboard
vim.keymap.set("n", "<leader>x", '"+d', { desc = "Cut to clipboard" })
vim.keymap.set("v", "<leader>x", '"+d', { desc = "Cut to clipboard" })
--
-- move line up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Line Down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Line Up" })

-- better indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("n", "<", "<S-v><<esc>", { desc = "Select line and indent left" })
vim.keymap.set("n", ">", "<S-v>><esc>", { desc = "Select line and indent right" })

-- open current file in python interactive session
vim.keymap.set("n", "<leader>t", function()
  local currentfile = vim.fn.expand("%")
  vim.cmd("new")
  vim.cmd("terminal python3 -i " .. currentfile)
end, { desc = "Run File in Python Terminal" })

-- Plugins
-- ###################

-- Open Zoxide telescope extension
vim.keymap.set("n", "<leader>Z", "<cmd>Zi<CR>", { desc = "Open Zoxide" })

-- Obsidian
vim.keymap.set(
  "n",
  "<leader>oc",
  "<cmd>lua require('obsidian').util.toggle_checkbox()<CR>",
  { desc = "Obsidian Check Checkbox" }
)
vim.keymap.set("n", "<leader>ot", "<cmd>ObsidianTemplate<CR>", { desc = "Insert Obsidian Template" })
vim.keymap.set("n", "<leader>oo", "<cmd>ObsidianOpen<CR>", { desc = "Open in Obsidian App" })
vim.keymap.set("n", "<leader>ob", "<cmd>ObsidianBacklinks<CR>", { desc = "Show ObsidianBacklinks" })
vim.keymap.set("n", "<leader>ou", "<cmd>ObsidianLinks<CR>", { desc = "Show ObsidianLinks" })
vim.keymap.set("n", "<leader>of", "<cmd>ObsidianFollowLink<CR>", { desc = "Follow Obsidian Link" })
vim.keymap.set("n", "<leader>ol", "<cmd>ObsidianLink<CR>", { desc = "Create Obsidian Link" })
vim.keymap.set("n", "<leader>oe", "<cmd>ObsidianExtractNote<CR>", { desc = "Extract to New Note" })
vim.keymap.set("n", "<leader>on", "<cmd>ObsidianNew<CR>", { desc = "Create New Note" })
vim.keymap.set("n", "<leader>oj", "<cmd>ObsidianToday<CR>", { desc = "Create New Daily Note" })
vim.keymap.set("n", "<leader>os", "<cmd>ObsidianSearch<CR>", { desc = "Search Obsidian" })
vim.keymap.set("n", "<leader>oq", "<cmd>ObsidianQuickSwitch<CR>", { desc = "Quick Switch" })

-- Markdown
vim.keymap.set("n", "<leader>md", "<cmd>MarkdownPreviewToggle<CR>", { desc = "Toggle Markdown Preview" })
vim.keymap.set("v", "<leader>mb", "di**<esc>p`]a**", { desc = "Bold Selection" })
vim.keymap.set("v", "<leader>mi", "di*<esc>p`]a*", { desc = "Italisize Selection" })
vim.keymap.set("v", "<leader>ml", "di[<esc>p`]a]()<esc>i", { desc = "Auto Link Selection" })
vim.keymap.set("v", "<leader>mc", "di`<esc>p`]a`", { desc = "Backtick Selection" })
vim.keymap.set("v", "<leader>mw", "di[[<esc>p`]a]]<esc>", { desc = "Wiki Link Selection" })

-- Zen Mode
vim.keymap.set("n", "<leader>zh", function()
  require("zen-mode").toggle({
    window = {
      width = 120,
      options = {
        -- signcolumn = "no", -- disable signcolumn
        number = false, -- disable number column
        relativenumber = false, -- disable relative numbers
        -- cursorline = false, -- disable cursorline
        -- cursorcolumn = false, -- disable cursor column
        -- foldcolumn = "0", -- disable fold column
        -- list = false, -- disable whitespace characters
      },
    },
  })
end, { desc = "Toggle Zen Mode without line numbers" })
vim.keymap.set("n", "<leader>zl", function()
  require("zen-mode").toggle({
    window = {
      width = 120,
      options = {
        -- signcolumn = "no", -- disable signcolumn
        number = true, -- enable number column
        relativenumber = true, -- enable relative numbers
        -- cursorline = false, -- disable cursorline
        -- cursorcolumn = false, -- disable cursor column
        -- foldcolumn = "0", -- disable fold column
        -- list = false, -- disable whitespace characters
      },
    },
  })
end, { desc = "Toggle Zen Mode with Line Numbers" })
