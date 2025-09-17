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
vim.keymap.set({'n','v','i'}, '<C-c>', '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set('n', '<C-v>', '"+p', { desc = "Paste from system clipboard" })
vim.keymap.set('i', '<C-v>', '<C-R>+', { desc = "Paste from system clipboard in insert mode" })

-- ======================
-- Bootstrap Packer
-- ======================
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd [[packadd packer.nvim]]
end

-- ======================
-- Global Packer floating function
-- ======================
function _G.open_packer_float()
  require('packer').init({
    display = {
      open_fn = function()
        return require('packer.util').float({ border = "rounded" })
      end
    }
  })
  vim.cmd('PackerSync')
end

vim.keymap.set('n', '<leader>P', _G.open_packer_float, { desc = "Open Packer in floating window" })

-- ======================
-- Plugins
-- ======================
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- Theme
  use { 'catppuccin/nvim', as = 'catppuccin' }

  -- Dashboard
  use 'goolord/alpha-nvim'

  -- File manager
  use { 'nvim-neo-tree/neo-tree.nvim', branch = 'v3.x', requires = { 
    'nvim-lua/plenary.nvim', 'nvim-tree/nvim-web-devicons', 'MunifTanjim/nui.nvim' 
  } }

  -- Telescope
  use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' } }

  -- Statusline
  use { 'nvim-lualine/lualine.nvim', requires = { 'nvim-tree/nvim-web-devicons' } }

  -- Command bar
  use { 'folke/noice.nvim', requires = { 'MunifTanjim/nui.nvim', 'rcarriga/nvim-notify' } }

  -- Treesitter
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

  -- Auto pairs
  use {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup{}
    end
  }
end)

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
    "", "", -- extra padding above logo
    [[  ███████╗██╗   ██╗██████╗ ███████╗██████╗ ███╗   ██╗ ██████╗ ██╗   ██╗ █████╗  ]],
    [[  ██╔════╝██║   ██║██╔══██╗██╔════╝██╔══██╗████╗  ██║██╔═══██╗██║   ██║██╔══██╗ ]],
    [[  ███████╗██║   ██║██████╔╝█████╗  ██████╔╝██╔██╗ ██║██║   ██║██║   ██║███████║ ]],
    [[  ╚════██║██║   ██║██╔═══╝ ██╔══╝  ██╔═══╝ ██║╚██╗██║██║   ██║╚██╗ ██╔╝██╔══██║ ]],
    [[  ███████║╚██████╔╝██║     ███████╗██║     ██║ ╚████║╚██████╔╝ ╚████╔╝ ██║  ██║ ]],
    [[  ╚══════╝ ╚═════╝ ╚═╝     ╚══════╝╚═╝     ╚═╝  ╚═══╝ ╚═════╝   ╚═══╝  ╚═╝  ╚═╝ ]],
    [[                                     neovim                                     ]],
  }

  -- Dashboard buttons
  dashboard.section.buttons.val = {
    dashboard.button("e", "  New file", ":ene <BAR> startinsert<CR>"),
    dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
    dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
    dashboard.button("p", "  Open Packer", ":lua _G.open_packer_float()<CR>"),
    dashboard.button("q", "  Quit NVIM", ":qa<CR>"),
  }

  -- push buttons further down
  local button_padding = 3
  for i = 1, button_padding do
    table.insert(dashboard.section.buttons.val, 1, { type = "padding", val = 1 })
  end

  alpha.setup(dashboard.opts)
end

-- Neo-tree configuration (<space>e)
pcall(function()
  require("neo-tree").setup({})
  vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "File Explorer" })
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

-- Treesitter setup (safe)
pcall(function()
  require'nvim-treesitter.configs'.setup {
    highlight = { enable = true },
    indent = { enable = true },
  }
end)

