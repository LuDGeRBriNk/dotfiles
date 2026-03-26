-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- 'nvim_create_autocmd' tells Neovim to "watch" for a specific event.
-- In this case, we are watching the "FileType" event.
vim.api.nvim_create_autocmd("FileType", {

  -- This acts as a filter. The code inside 'callback' will ONLY run
  -- if the file being opened matches one of these extensions/types.
  pattern = { "html", "css", "javascript", "json" },

  -- The 'callback' is a function (a block of code) that executes
  -- immediately when the 'FileType' event and 'pattern' match.
  callback = function()
    -- 'vim.opt_local' is crucial here. It ensures the change ONLY
    -- applies to the current file (buffer).
    -- If you open a Python file in another tab, it will still use 4 spaces.

    -- Sets the indentation jump to 2 spaces for these specific web files.
    vim.opt_local.shiftwidth = 2

    -- Sets the visual width of a tab character to 2 spaces for these files.
    vim.opt_local.tabstop = 2
  end, -- Marks the end of the function.
})
