-- Automatically add bulletpoints on the next line respecting indentation
--
-- When in insert mode, you can increase indentation with ctrl+t and decrease it
-- with ctrl+d
--
-- By default it's enabled on filetypes 'markdown', 'text', 'gitcommit', 'scratch'
-- https://github.com/bullets-vim/bullets.vim

return {
  "bullets-vim/bullets.vim",
  config = function()
    -- Disable deleting the last empty bullet when pressing <cr> or 'o'
    -- default = 1
    vim.g.bullets_delete_last_bullet_if_empty = 1

    -- Disable adding default key mappings
    vim.g.bullets_set_mappings = 0

    -- Custom mappings
    vim.g.bullets_custom_mappings = {
      { "imap", "<CR>", "<Plug>(bullets-newline)" },
      { "inoremap", "<C-CR>", "<CR>" },
      { "nmap", "o", "<Plug>(bullets-newline)" },
      { "vmap", "gN", "<Plug>(bullets-renumber)" },
      { "nmap", "gN", "<Plug>(bullets-renumber)" },
      { "nmap", "<leader>k", "<Plug>(bullets-toggle-checkbox)" },
      { "imap", "<C-t>", "<Plug>(bullets-demote)" },
      { "nmap", ">>", "<Plug>(bullets-demote)" },
      { "vmap", ">", "<Plug>(bullets-demote)" },
      { "imap", "<C-d>", "<Plug>(bullets-promote)" },
      { "nmap", "<<", "<Plug>(bullets-promote)" },
      { "vmap", "<", "<Plug>(bullets-promote)" },
    }
  end,
}
