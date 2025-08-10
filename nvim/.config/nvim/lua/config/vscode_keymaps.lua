local opts = { noremap = true, silent = true }

-- remap leader key
vim.keymap.set("n", "<Space>", "", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- for alternative syntax:
-- vim.keymap.set("", "", function () vscode.call(""") end, {})

-- ###################
-- Window & Workspace Management
-- ###################

-- Window Management
vim.keymap.set("n", "<leader>w", "<cmd>lua require('vscode').actionvim.('workbench.action.openWindow')<CR>",
    { desc = "Open window" })

-- Window Navigation
vim.keymap.set("n", "<C-h>", "<cmd>lua require('vscode').actionvim.('workbench.action.navigateLeft')<CR>",
    { desc = "Navigate left" })
vim.keymap.set("n", "<C-l>", "<cmd>lua require('vscode').actionvim.('workbench.action.navigateRight')<CR>",
    { desc = "Navigate right" })
vim.keymap.set("n", "<C-j>", "<cmd>lua require('vscode').action('workbench.action.navigateDown')<CR>",
    { desc = "Navigate down" })
vim.keymap.set("n", "<C-k>", "<cmd>lua require('vscode').action('workbench.action.navigateUp')<CR>",
    { desc = "Navigate up" })
-- View Modes
vim.keymap.set("n", "<leader>z", "<cmd>lua require('vscode').actionvim.('workbench.action.toggleZenMode')<CR>",
    { desc = "Toggle zen mode" })

-- Split Management
vim.keymap.set("n", "<leader>wv", "<cmd>lua require('vscode').action('workbench.action.splitEditor')<CR>",
    { desc = "Split vertical" })
vim.keymap.set("n", "<leader>wh", "<cmd>lua require('vscode').action('workbench.action.splitEditorOrthogonal')<CR>",
    { desc = "Split horizontal" })
vim.keymap.set("n", "<leader>wc", "<cmd>lua require('vscode').action('workbench.action.joinTwoGroups')<CR>",
    { desc = "Close split" })

-- Panel and Explorer Toggles
vim.keymap.set("n", "<leader>up", "<cmd>lua require('vscode').action('workbench.action.togglePanel')<CR>",
    { desc = "Toggle panel" })
vim.keymap.set("n", "<leader>u", "<cmd>lua require('vscode').actionvim.('workbench.action.toggleSidebarVisibility')<CR>",
    { desc = "Toggle sidebar visibility" })
vim.keymap.set("n", "<leader>u", "<cmd>lua require('vscode').actionvim.('workbench.action.toggleGlobalActivityBar')<CR>",
    { desc = "Toggle global activity bar" })
vim.keymap.set("n", "<leader>e", "<cmd>lua require('vscode').actionvim.('workbench.files.action.focusFilesExplorer')<CR>",
    { desc = "Focus explorer" })
vim.keymap.set("n", "<leader>fe", "<cmd>lua require('vscode').actionvim.('workbench.action.toggleFileExplorer')<CR>",
    { desc = "Toggle file explorer" })
vim.keymap.set("n", "<leader>t", "<cmd>lua require('vscode').actionvim.('workbench.action.terminal.toggleTerminal')<CR>",
    { desc = "Toggle terminal" })
vim.keymap.set("n", "<leader>tn", "<cmd>lua require('vscode').actionvim.('workbench.action.createTerminalEditor')<CR>",
    { desc = "Create new terminal" })

-- Settings and Help
vim.keymap.set("n", "<leader>l", "<cmd>lua require('vscode').actionvim.('workbench.action.openLog')<CR>",
    { desc = "Open log" })

-- ###################
-- Editor Navigation
-- ###################

-- Tab and Editor Management
vim.keymap.set("n", "<S-l>", "<cmd>lua require('vscode').actionvim.('workbench.action.nextEditor')<CR>",
    { desc = "Next editor" })
vim.keymap.set("n", "<S-h>", "<cmd>lua require('vscode').actionvim.('workbench.action.previousEditor')<CR>",
    { desc = "Previous editor" })
vim.keymap.set("n", "<S-j>", "<cmd>lua require('vscode').actionvim.('workbench.action.nextEditorInGroup')<CR>",
    { desc = "Next editor in group" })
vim.keymap.set("n", "<S-k>", "<cmd>lua require('vscode').actionvim.('workbench.action.previousEditorInGroup')<CR>",
    { desc = "Previous editor in group" })
vim.keymap.set("n", "<leader>bo", "<cmd>lua require('vscode').actionvim.('workbench.action.closeOtherEditors')<CR>",
    { desc = "Close other editors" })
vim.keymap.set("n", "<leader>qq", "<cmd>lua require('vscode').actionvim.('workbench.action.closeActiveEditor')<CR>",
    { desc = "Close active editor" })
vim.keymap.set("n", "<leader>,", "<cmd>lua require('vscode').actionvim.('workbench.action.showAllEditors')<CR>",
    { desc = "Show all editors" })

-- Code Navigation
vim.keymap.set("n", "gr", "<cmd>lua require('vscode').actionvim.('editor.action.goToReferences')<CR>",
    { desc = "Go to references" })
vim.keymap.set("n", "gi", "<cmd>lua require('vscode').actionvim.('editor.action.goToImplementation')<CR>",
    { desc = "Go to implementation" })

-- ###################
-- Code Actions & Editing
-- ###################

-- Code Folding
vim.keymap.set("n", "zM", "<cmd>lua require('vscode').call('editor.foldAll')<CR>", { desc = "Fold all code sections" })
vim.keymap.set("n", "zR", "<cmd>lua require('vscode').call('editor.unfoldAll')<CR>",
    { desc = "Unfold all code sections" })
vim.keymap.set("n", "zc", "<cmd>lua require('vscode').call('editor.fold')<CR>", { desc = "Fold current section" })
vim.keymap.set("n", "zC", "<cmd>lua require('vscode').call('editor.foldRecursively')<CR>",
    { desc = "Fold current section recursively" })
vim.keymap.set("n", "zo", "<cmd>lua require('vscode').call('editor.unfold')<CR>", { desc = "Unfold current section" })
vim.keymap.set("n", "zO", "<cmd>lua require('vscode').call('editor.unfoldRecursively')<CR>",
    { desc = "Unfold current section recursively" })
vim.keymap.set("n", "za", "<cmd>lua require('vscode').call('editor.toggleFold')<CR>",
    { desc = "Toggle fold current section" })

-- Code Information and Hints
vim.keymap.set("i", "<c-k>", "<cmd>lua require('vscode').actionvim.('editor.action.triggerParameterHints')<CR>",
    { desc = "Trigger parameter hints" })

-- Code Actions
vim.keymap.set({ "n", "v" }, "<leader>ca", "<cmd>lua require('vscode').actionvim.('editor.action.quickFix')<CR>",
    { desc = "Quick fix actions" })
vim.keymap.set("n", "<leader>cA", "<cmd>lua require('vscode').actionvim.('editor.action.sourceAction')<CR>",
    { desc = "Open source action" })
vim.keymap.set("n", "<leader>cr", "<cmd>lua require('vscode').actionvim.('editor.action.rename')<CR>",
    { desc = "Rename symbol" })
vim.keymap.set("n", "<leader>ci", "<cmd>lua require('vscode').action('editor.action.triggerSuggest')<CR>",
    { desc = "Trigger suggestions" })

-- Formatting
vim.keymap.set("v", "<leader>cf", "<cmd>lua require('vscode').action('editor.action.formatSelection')<CR>",
    { desc = "Format selection" })
vim.keymap.set({ "n", "v" }, "<leader>cF", "<cmd>lua require('vscode').action('editor.action.formatDocument')<CR>",
    { desc = "Format document" })

-- ###################
-- Search and File Operations
-- ###################

-- File Search and Navigation
vim.keymap.set("n", "<leader><space>", "<cmd>lua require('vscode').action('workbench.action.quickOpen')<CR>",
    { desc = "Find files" })
vim.keymap.set({ "n", "v" }, "<leader>ff", "<cmd>lua require('vscode').actionvim.('workbench.action.quickOpen')<CR>",
    { desc = "Quick open files" })
vim.keymap.set("n", "<leader>/", "<cmd>lua require('vscode').actionvim.('workbench.action.quickTextSearch')<CR>",
    { desc = "Quick text search" })
vim.keymap.set("n", "<leader>sg", "<cmd>lua require('vscode').action('workbench.action.findInFiles')<CR>",
    { desc = "Grep files" })
vim.keymap.set("n", "<leader>sr", "<cmd>lua require('vscode').action('workbench.action.replaceInFiles')<CR>",
    { desc = "Search & replace" })

-- Symbol Search
vim.keymap.set("n", "<leader>ss", "<cmd>lua require('vscode').action('workbench.action.gotoSymbol')<CR>",
    { desc = "Go to symbol" })
vim.keymap.set("n", "<leader>sS", "<cmd>lua require('vscode').action('workbench.action.showAllSymbols')<CR>",
    { desc = "Workspace symbols" })

-- Special File Operations
vim.keymap.set("n", "<leader><Cr>", "<cmd>lua require('vscode').actionvim.('oil-code.open')<CR>",
    { desc = "Open oil code" })

-- ###################
-- Debugging and Development
-- ###################

-- Debugging
vim.keymap.set("n", "<leader>b", "<cmd>lua require('vscode').actionvim.('editor.debug.action.toggleBreakpoint')<CR>",
    { desc = "Toggle breakpoint" })

-- Code Execution
vim.keymap.set({ "n", "v" }, "<leader>pr", "<cmd>lua require('vscode').actionvim.('code-runner.run')<CR>",
    { desc = "Run code" })

-- ###################
-- Problems & Diagnostics
-- ###################

-- Problem Navigation
vim.keymap.set("n", "]d", "<cmd>lua require('vscode').action('editor.action.marker.nextInFiles')<CR>",
    { desc = "Next diagnostic" })
vim.keymap.set("n", "[d", "<cmd>lua require('vscode').action('editor.action.marker.prevInFiles')<CR>",
    { desc = "Previous diagnostic" })

-- Problem Panel
vim.keymap.set("n", "<leader>xx", "<cmd>lua require('vscode').action('workbench.actions.view.problems')<CR>",
    { desc = "Open problems" })
vim.keymap.set({ "n", "v" }, "<leader>xl", "<cmd>lua require('vscode').actionvim.('workbench.action.problems.focus')<CR>",
    { desc = "Focus problems panel" })
vim.keymap.set("n", "<leader>xc", "<cmd>lua require('vscode').action('workbench.actions.problems.clear')<CR>",
    { desc = "Clear problems" })

-- Notifications
vim.keymap.set("n", "<leader>xn", "<cmd>lua require('vscode').action('notifications.clearAll')<CR>",
    { desc = "Clear notifications" })

-- ###################
-- Git Integration
-- ###################

-- Git Operations
vim.keymap.set("n", "<leader>gg", "<Cmd>call VSCodeNotify('lazygit.openLazygit')<CR>", { desc = "Open LazyGit" })
