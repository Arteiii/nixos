

require("neo-tree").setup({
  close_if_last_window = true,
  popup_border_style = "rounded",
  filesystem = {
    follow_current_file = true,
    use_libuv_file_watcher = true,
  },
  window = {
    mappings = {
      ["<C-n>"] = "toggle",  -- Map Ctrl + n to toggle Neo-tree
      ["<CR>"] = "open",      -- Open file or directory
      ["l"] = "open",         -- Same as <CR>, but can be more ergonomic
      ["h"] = "close_node",   -- Close directory or go up a level
      ["v"] = "vsplit",       -- Open file in a vertical split
      ["s"] = "split",        -- Open file in a horizontal split
    },
  },
})

vim.api.nvim_set_keymap('n', '<C-n>', ':Neotree toggle<CR>', { noremap = true, silent = true })

