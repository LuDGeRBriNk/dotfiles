-- This file contains all plugins related to Git version control.

return {
  -- 1. Gitsigns: Provides "signs" in the gutter (beside line numbers)
  -- to show added, modified, or deleted lines in real-time.
  {
    "lewis6991/gitsigns.nvim",
    -- 'opts' is a shorthand in lazy.nvim to call the plugin's setup() function.
    opts = {
      -- Inline 'Git Blame' showing who committed the current line and when.
      current_line_blame = true,
    },
  },

  -- 2. Neogit: A powerful, full-screen Git interface for Neovim.
  -- It is inspired by Magit (from Emacs) and simplifies staging/committing.
  {
    "NeogitOrg/neogit",
    -- Dependencies are plugins that must be loaded for Neogit to work properly.
    dependencies = {
      "nvim-lua/plenary.nvim", -- A library of Lua functions used by many plugins.
      "sindrets/diffview.nvim", -- Adds a side-by-side view for diffs and merge conflicts.
    },
    -- Setting 'config = true' tells lazy.nvim to run the default setup() automatically.
    config = true,
  },
}
