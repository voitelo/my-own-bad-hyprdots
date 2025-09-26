-- ~/.config/nvim/init.lua
-- SUPERNOVA Neovim ✨

-- ======================
-- General options
-- ======================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.cursorline = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.clipboard = "unnamedplus"

-- Leader key
vim.g.mapleader = " "

-- ======================
-- Clipboard keymaps
-- ======================
vim.keymap.set('n', 'y', '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set('n', 'yy', '"+yy', { desc = "Yank line to system clipboard" })
vim.keymap.set('v', 'y', '"+y', { desc = "Yank selection to system clipboard" })
vim.keymap.set('i', '<C-v>', '<C-R>+', { desc = "Paste from system clipboard in insert mode" })
vim.keymap.set('n', '<C-v>', '"+p', { desc = "Paste from system clipboard" })

-- ======================
-- Bootstrap lazy.nvim
-- ======================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ======================
-- Plugins
-- ======================
require("lazy").setup({
  -- Theme
  { "catppuccin/nvim", name = "catppuccin" },

  -- Dashboard
  "goolord/alpha-nvim",

  -- File manager
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- Command bar
  {
    "folke/noice.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
  },

  -- Treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup {}
    end,
  },

  -- VimBeGood
  "ThePrimeagen/vim-be-good",
})

-- ======================
-- Plugin Configuration
-- ======================

-- Catppuccin Mocha theme
pcall(function()
  require("catppuccin").setup({
    flavour = "mocha",
    integrations = {
      alpha = true,
      telescope = true,
      lualine = true,
      treesitter = true,
      neotree = true,
      notify = true,
    },
  })
  vim.cmd.colorscheme("catppuccin")
end)

-- Dashboard (Alpha) with SUPERNOVA logo
local status_alpha, alpha = pcall(require, "alpha")
if status_alpha then
  local dashboard = require("alpha.themes.dashboard")
  dashboard.section.header.opts.spacing = 2

  dashboard.section.header.val = {
    "", "",
    [[  ███████╗██╗   ██╗██████╗ ███████╗██████╗ ███╗   ██╗ ██████╗ ██╗   ██╗ █████╗  ]],
    [[  ██╔════╝██║   ██║██╔══██╗██╔════╝██╔══██╗████╗  ██║██╔═══██╗██║   ██║██╔══██╗ ]],
    [[  ███████╗██║   ██║██████╔╝█████╗  ██████╔╝██╔██╗ ██║██║   ██║██║   ██║███████║ ]],
    [[  ╚════██║██║   ██║██╔═══╝ ██╔══╝  ██╔═══╝ ██║╚██╗██║██║   ██║╚██╗ ██╔╝██╔══██║ ]],
    [[  ███████║╚██████╔╝██║     ███████╗██║     ██║ ╚████║╚██████╔╝ ╚████╔╝ ██║  ██║ ]],
    [[  ╚══════╝ ╚═════╝ ╚═╝     ╚══════╝╚═╝     ╚═╝  ╚═══╝ ╚═════╝   ╚═══╝  ╚═╝  ╚═╝ ]],
    [[                                     neovim                                     ]],
  }

  dashboard.section.buttons.val = {
    dashboard.button("e", "  New file", ":ene <BAR> startinsert<CR>"),
    dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
    dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
    dashboard.button("l", "󰒲  Plugins", ":Lazy<CR>"), -- Only opens Lazy when you click it
    dashboard.button("q", "  Quit NVIM", ":qa<CR>"),
  }

  local button_padding = 3
  for i = 1, button_padding do
    table.insert(dashboard.section.buttons.val, 1, { type = "padding", val = 1 })
  end

  alpha.setup(dashboard.opts)
end

-- Neo-tree config
pcall(function()
  require("neo-tree").setup({})
  vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "File Explorer" })
  vim.keymap.set("n", "<S-M-h>", ":Neotree reveal ~/dotfiles<CR>", { desc = "Open dotfiles" })
end)

-- Telescope setup
pcall(function()
  require("telescope").setup({})
end)

-- Lualine setup
pcall(function()
  require("lualine").setup({
    options = { theme = "catppuccin" },
  })
end)

-- Noice setup
pcall(function()
  require("noice").setup({
    lsp = { progress = { enabled = false } },
    presets = { command_palette = true },
  })
end)

-- Treesitter setup
pcall(function()
  require("nvim-treesitter.configs").setup {
    highlight = { enable = true },
    indent = { enable = true },
  }
end)

