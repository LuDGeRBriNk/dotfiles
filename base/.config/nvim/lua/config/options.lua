-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Create a local alias for vim.opt to make the configuration cleaner and easier to type.
-- Instead of typing 'vim.opt.option_name', you can just use 'opt.option_name'.
local opt = vim.opt

-- Enables 'soft wrapping.' If a line of text is longer than the width of the window,
-- it will continue on the next visual line. It does NOT insert actual line breaks
-- into the file; it only affects how the text is displayed.
opt.wrap = true

-- Refines the 'wrap' behavior. When true, Neovim will wait for a 'break character'
-- (like a space or punctuation) before wrapping to the next line. This prevents
-- words from being chopped in half at the edge of the screen.
opt.linebreak = true

-- Sets the number of visual spaces that a literal Tab character (\t) represents
-- in the editor. In this case, one Tab will look as wide as 4 spaces.
opt.tabstop = 4

-- Determines the number of spaces used for each level of automatic indentation
-- (e.g., when you press '>>' or when Neovim auto-indents after an opening brace).
opt.shiftwidth = 4

-- Disables 'Relative Line Numbers.' When false, the gutter shows the absolute
-- line number (1, 2, 3...) regardless of where your cursor is.
-- Useful if you prefer traditional navigation over "jump-to-line" distance logic.
opt.relativenumber = false

-- Point Neovim to a dedicated local Python virtual environment
-- -- This tells Neovim to use a specific Python executable for its Python 3 host
-- provider. This is crucial for plugins that rely on Python 3 (like 'pynvim')
-- to function correctly, ensuring they use the Python interpreter within your
-- specified virtual environment.
vim.g.python3_host_prog = vim.fn.expand("~/.local/share/nvim/venv/bin/python")
