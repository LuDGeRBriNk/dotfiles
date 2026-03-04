-- ==============================================================================
-- 1. BASE SETTINGS
-- ==============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt
opt.number = true
--opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.cursorline = true
opt.ignorecase = true
opt.smartcase = true
opt.termguicolors = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

-- Enable text wrapping for side-by-side screens
opt.wrap = true       -- Visually wrap long lines
opt.linebreak = true  -- Wrap at whole words instead of breaking in the middle

-- Specific indentation for web dev files
vim.cmd([[autocmd FileType html,css,javascript,json setlocal shiftwidth=2 tabstop=2]])


-- ==============================================================================
-- 2. POPUP MENU SETTINGS
-- ==============================================================================

-- 1. KILL the default Neovim background task that causes the popup error
pcall(function()
    -- Target the exact group Neovim 0.10+ uses for the default menu
    vim.api.nvim_clear_autocmds({ group = "nvim.popupmenu" })
end)

-- 2. Safely wipe the default menu
vim.cmd('silent! aunmenu PopUp')


-- ==============================================================================
-- 3. PLUGIN MANAGER (lazy.nvim)
-- ==============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)


-- ==============================================================================
-- 4. PLUGINS & CONFIGURATION
-- ==============================================================================
require("lazy").setup({
  
  -- Theme: Monokai (Forced to load immediately)
  {
    "tanvirtin/monokai.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require('monokai').setup { palette = require('monokai').pro }
      vim.cmd.colorscheme("monokai_pro")
    end
  },

  -- File Explorer: Nvim-Tree
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 30, -- Set the permanent width of the left column when toggled
        },
        -- Enables Auto-Focus to track the current file
        update_focused_file = {
          enable = true,
        },
        actions = {
          change_dir = {
            -- FALSE: Forces folders to expand/collapse instead of changing the root
            enable = false, 
          },
        },
        renderer = {
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
            },
            glyphs = {
              folder = {
                arrow_closed = "▶",
                arrow_open = "▼",
              },
            },
          },
        },
      })
      -- Press Ctrl+n to manually toggle the file tree
      vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { silent = true })
    end
  },

  -- Fuzzy Finder: Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require('telescope.builtin')
      -- Ctrl+p to find files quickly without needing the file tree
      vim.keymap.set('n', '<C-p>', builtin.find_files, {})
      vim.keymap.set('n', '<leader>rg', builtin.live_grep, {})
    end
  },

  -- Oil for ssh/editing file system as a buffer
  {
    'stevearc/oil.nvim',
    opts = {},
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- Syntax Highlighting: Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      -- Protected call to prevent crashes on the first run before installation finishes
      local status_ok, configs = pcall(require, "nvim-treesitter.configs")
      if not status_ok then
        return 
      end

      configs.setup({
        ensure_installed = { "c", "python", "html", "css", "javascript", "sql", "lua", "vim", "vimdoc" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end
  },

  -- Status Line: Lualine
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require('lualine').setup({
        options = { theme = 'auto' }
      })
    end
  },

  -- LSP Installer: Mason
  {
    "williamboman/mason.nvim",
    config = function() require("mason").setup() end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "clangd", "html", "cssls", "ts_ls" }
      })
    end
  },

  -- Native LSP & Autocompletion Core
  "neovim/nvim-lspconfig",
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "L3MON4D3/LuaSnip",
})


-- ==============================================================================
-- 5. AUTOCOMPLETION SETUP (nvim-cmp)
-- ==============================================================================
local cmp = require('cmp')
cmp.setup({
  snippet = {
    expand = function(args) require('luasnip').lsp_expand(args.body) end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_next_item() else fallback() end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_prev_item() else fallback() end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  })
})


-- ==============================================================================
-- 6. ATTACH LSP TO BUFFERS (Connecting completion to languages)
-- ==============================================================================
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Neovim 0.11+ Native LSP Configuration
local servers = { "pyright", "clangd", "html", "cssls", "ts_ls" }

for _, server in ipairs(servers) do
    vim.lsp.config(server, {
        capabilities = capabilities
    })
    vim.lsp.enable(server)
end

-- LSP Keybinds
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {})