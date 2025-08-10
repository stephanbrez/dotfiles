-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- ###################
-- Navigation
-- ###################
-- vim.keymap.set("i", "<CR>", "<Esc>", { noremap = true, silent = true })
local wk = require("which-key")

-- Center cursor after scroll
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Jump between markdown headers
vim.keymap.set("n", "gj", [[/^##\+ .*<CR>]], { buffer = true, silent = true, desc = "Jump to next markdown header" })
vim.keymap.set(
    "n",
    "gk",
    [[?^##\+ .*<CR>]],
    { buffer = true, silent = true, desc = "Jump to previous markdown header" }
)

-- ###################
-- Editing
-- ###################
-- Autocmd to store the starting line when entering insert mode
vim.api.nvim_create_autocmd("InsertEnter", {
    pattern = "*",
    callback = function()
        -- Store the current line number when entering insert mode
        vim.b.insertLineStart = vim.fn.line(".")
    end,
})

-- Function to handle Down arrow key in insert mode
function InsertModeDown()
    local current_line = vim.fn.line(".")
    local insert_line_start = vim.b.insertLineStart or current_line

    -- Exit insert mode if cursor moves more than one line down
    if current_line > insert_line_start + 1 then
        vim.cmd("stopinsert")
    end
    return "<Down>"
end

-- Function to handle Up arrow key in insert mode
function InsertModeUp()
    local current_line = vim.fn.line(".")
    local insert_line_start = vim.b.insertLineStart or current_line

    -- Exit insert mode if cursor moves more than one line up
    if current_line < insert_line_start - 1 then
        vim.cmd("stopinsert")
    end
    return "<Up>"
end

-- Key mappings for Up and Down arrows in insert mode
vim.keymap.set("i", "<Down>", function()
    return InsertModeDown()
end, { expr = true })
vim.keymap.set("i", "<Up>", function()
    return InsertModeUp()
end, { expr = true })

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
-- Move line up and down
-- vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Line Down" })
-- vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Line Up" })

-- better indenting
-- vim.keymap.set("v", "<", "<gv")
-- vim.keymap.set("v", ">", ">gv")
vim.keymap.set("n", "<", "<S-v><<esc>", { desc = "Select line and indent left" })
vim.keymap.set("n", ">", "<S-v>><esc>", { desc = "Select line and indent right" })

-- ###################
-- Terminal
-- ###################
-- open current file in python interactive session
vim.keymap.set("n", "<leader>t", function()
    local currentfile = vim.fn.expand("%")
    vim.cmd("new")
    vim.cmd("terminal python3 -i " .. currentfile)
end, { desc = "Run File in Python Terminal" })

local function rename_terminal()
    -- Get the current buffer number
    local bufnr = vim.api.nvim_get_current_buf()

    -- Check if the current buffer is a terminal buffer
    if vim.bo[bufnr].filetype == "terminal" then
        -- Execute the fc command to get the most recent command from Zsh history
        local cmd = "fc -l 1 | tail -n 1"
        local output = vim.fn.system(cmd)

        if output ~= "" then
            -- Remove any trailing characters like spaces or newlines
            local last_command = string.gsub(output, "%s+$", "")

            -- Escape the command to avoid issues with special characters
            last_command = vim.fn.fnameescape(last_command)

            -- Rename the terminal window
            vim.cmd("title " .. last_command)
        else
            vim.notify("No commands in terminal history", "WARNING")
        end
    else
        vim.notify("Not in a terminal buffer", "ERROR")
    end
end

-- Bind the function to a key sequence, e.g., <leader>tr
vim.keymap.set("n", "<leader>wr", rename_terminal, { desc = "Rename Terminal" })

-- ###################
-- Markdown
-- ###################

-- which-key menu groups
wk.add({
    {
        mode = { "n", "v" }, -- both normal and visual mode
        { "<leader>m", group = "markdown", icon = { icon = " ", color = "red" } },
        { "<leader>mh", group = "headings", icon = { icon = " ", color = "red" } },
    },
})

vim.keymap.set("n", "<leader>md", "<cmd>MarkdownPreviewToggle<CR>", { desc = "Toggle Markdown Preview" })

-- ===== Text Formatting =====
vim.keymap.set("v", "<leader>mb", "di**<esc>p`]a**", { desc = "Bold Selection" })
vim.keymap.set("v", "<leader>mi", "di*<esc>p`]a*", { desc = "Italisize Selection" })
vim.keymap.set("v", "<leader>ml", "di[<esc>p`]a]()<esc>i", { desc = "Auto Link Selection" })
vim.keymap.set("v", "<leader>mc", "di`<esc>p`]a`", { desc = "Backtick Selection" })
vim.keymap.set("v", "<leader>mw", "di[[<esc>p`]a]]<esc>", { desc = "Wiki Link Selection" })

-- ===== Headings =====
vim.keymap.set("n", "<leader>mj", ":/^#\\+ .*<CR>", { desc = "Jump to next markdown header" })
vim.keymap.set("n", "<leader>mk", ":?^#\\+ .*<CR>", { desc = "Jump to previous markdown header" })

vim.keymap.set("n", "<leader>mhi", function()
    local line = vim.api.nvim_get_current_line() -- Get the current line
    if line:match("^#+") then                    -- Check if the line starts with one or more '#'
        -- Increase heading level by adding another '#'
        local new_heading = line:gsub("^(#+)", function(h)
            return h .. "#"
        end)
        vim.api.nvim_set_current_line(new_heading) -- Set the new line
    else
        -- If it's not a heading, create a new heading
        vim.api.nvim_set_current_line("# " .. line)
    end
end, { desc = "Increase Heading Level" })

vim.keymap.set("n", "<leader>mhd", function()
    local line = vim.api.nvim_get_current_line() -- Get the current line
    if line:match("^#+") then                    -- Check if the line starts with one or more '#'
        -- Decrease heading level by removing one '#'
        local new_heading = line:gsub("^(#+)", function(h)
            return h:sub(2)                        -- Remove the first '#'
        end)
        vim.api.nvim_set_current_line(new_heading) -- Set the new line
    end
end, { desc = "Decrease Heading Level" })

vim.keymap.set("n", "<leader>mhI", function()
    -- Save the current cursor position
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    -- I'm using [[ ]] to escape the special characters in a command
    vim.cmd([[:g/\(^$\n\s*#\+\s.*\n^$\)/ .+1 s/^#\+\s/#&/]])
    -- Restore the cursor position
    vim.api.nvim_win_set_cursor(0, cursor_pos)
    -- Clear search highlight
    vim.cmd("nohlsearch")
end, { desc = "Increase ALL headings" })

vim.keymap.set("n", "<leader>mhD", function()
    -- Save the current cursor position
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    -- I'm using [[ ]] to escape the special characters in a command
    vim.cmd([[:g/^\s*#\{2,}\s/ s/^#\(#\+\s.*\)/\1/]])
    -- Restore the cursor position
    vim.api.nvim_win_set_cursor(0, cursor_pos)
    -- Clear search highlight
    vim.cmd("nohlsearch")
end, { desc = "Decrease ALL headings" })

-- ===== Bullets =====
-- Toggle bullet point at the beginning of the current line in normal mode
-- If in a multiline paragraph, make sure the cursor is on the line at the top
-- "d" is for "dash"
-- from https://linkarzu.com/posts/neovim/markdown-setup-2025/
vim.keymap.set("n", "<leader>md", function()
    -- Get the current cursor position
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local current_buffer = vim.api.nvim_get_current_buf()
    local start_row = cursor_pos[1] - 1
    local col = cursor_pos[2]
    -- Get the current line
    local line = vim.api.nvim_buf_get_lines(current_buffer, start_row, start_row + 1, false)[1]
    -- Check if the line already starts with a bullet point
    if line:match("^%s*%-") then
        -- Remove the bullet point from the start of the line
        line = line:gsub("^%s*%-", "")
        vim.api.nvim_buf_set_lines(current_buffer, start_row, start_row + 1, false, { line })
        return
    end
    -- Search for newline to the left of the cursor position
    local left_text = line:sub(1, col)
    local bullet_start = left_text:reverse():find("\n")
    if bullet_start then
        bullet_start = col - bullet_start
    end
    -- Search for newline to the right of the cursor position and in following lines
    local right_text = line:sub(col + 1)
    local bullet_end = right_text:find("\n")
    local end_row = start_row
    while not bullet_end and end_row < vim.api.nvim_buf_line_count(current_buffer) - 1 do
        end_row = end_row + 1
        local next_line = vim.api.nvim_buf_get_lines(current_buffer, end_row, end_row + 1, false)[1]
        if next_line == "" then
            break
        end
        right_text = right_text .. "\n" .. next_line
        bullet_end = right_text:find("\n")
    end
    if bullet_end then
        bullet_end = col + bullet_end
    end
    -- Extract lines
    local text_lines = vim.api.nvim_buf_get_lines(current_buffer, start_row, end_row + 1, false)
    local text = table.concat(text_lines, "\n")
    -- Add bullet point at the start of the text
    local new_text = "- " .. text
    local new_lines = vim.split(new_text, "\n")
    -- Set new lines in buffer
    vim.api.nvim_buf_set_lines(current_buffer, start_row, end_row + 1, false, new_lines)
end, { desc = "[P]Toggle bullet point (dash)" })

-- ###################
-- Plugins
-- ###################

-- Open Zoxide telescope extension
vim.keymap.set("n", "<leader>Z", "<cmd>Zi<CR>", { desc = "Open Zoxide" })

-- Bullets
vim.keymap.set("n", "<leader>k", "<Plug>(bullets-toggle-checkbox)", { desc = "Toggle Checkbox" })

-- Obsidian
wk.add({
    { "<leader>o", group = "obsidian", mode = { "n", "v" }, icon = { icon = "󰂺 ", color = "blue" } },
})

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
vim.keymap.set("v", "<leader>ol", "<cmd>ObsidianLink<CR>", { desc = "Create Obsidian Link" })
vim.keymap.set("v", "<leader>oe", "<cmd>ObsidianExtractNote<CR>", { desc = "Extract to New Note" })
vim.keymap.set("n", "<leader>on", "<cmd>ObsidianNew<CR>", { desc = "Create New Note" })
vim.keymap.set("n", "<leader>oj", "<cmd>ObsidianToday<CR>", { desc = "Create New Daily Note" })
vim.keymap.set("n", "<leader>os", "<cmd>ObsidianSearch<CR>", { desc = "Search Obsidian" })
vim.keymap.set("n", "<leader>oq", "<cmd>ObsidianQuickSwitch<CR>", { desc = "Quick Switch" })

-- Zen Mode
wk.add({
    { "<leader>z", group = "zen-mode", icon = { icon = " ", color = "grey" } },
})

vim.keymap.set("n", "<leader>zh", function()
    require("zen-mode").toggle({
        window = {
            width = 120,
            options = {
                -- signcolumn = "no", -- disable signcolumn
                number = false,         -- disable number column
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
                number = true,         -- enable number column
                relativenumber = true, -- enable relative numbers
                -- cursorline = false, -- disable cursorline
                -- cursorcolumn = false, -- disable cursor column
                -- foldcolumn = "0", -- disable fold column
                -- list = false, -- disable whitespace characters
            },
        },
    })
end, { desc = "Toggle Zen Mode with Line Numbers" })

if vim.g.vscode then
    print("⚡connected to neovim!💯‼️🤗😎")
    require "vscode_keymaps"
end
