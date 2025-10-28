-- ~/.config/nvim/init.lua
-- EVERFOREST Neovim 🌿

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
  -- Theme 🌿
  { "sainnhe/everforest" },

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

  -- Color highlight (inline color blocks)
  {
    "brenoprata10/nvim-highlight-colors",
    config = function()
      require("nvim-highlight-colors").setup({
        render = 'virtual',
        virtual_text = '■',
        enable_tailwind = true,
        enable_named_colors = true,
      })
    end
  },

  -- Which-key 🗝️
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({
        plugins = { spelling = true },
        win = { border = "rounded", padding = {1,2}, zindex = 1000 },
        layout = { align = "center" },
      })
    end,
  },

  -- Optional: mini.icons
  { "echasnovski/mini.icons", version = false },

  -- Comfy line numbers
  {
    "mluders/comfy-line-numbers.nvim",
    config = function()
      require("comfy-line-numbers").setup({
        formatter = function(line, top, bottom, cursor)
          local rel = line - cursor
          local abs_rel = math.abs(rel)
          if abs_rel == 0 then
            return "0"
          elseif abs_rel <= 3 then
            return tostring(abs_rel)
          else
            return tostring(10 + (abs_rel % 3))
          end
        end,
      })
    end
  },

  -- Twilight (block mode)
  {
    "folke/twilight.nvim",
    config = function()
      require("twilight").setup({ expand = { "block" } })
      vim.keymap.set("n", "<leader>z", ":Twilight<CR>", { desc = "Toggle Twilight" })
    end
  },

  -- nvim-toggler
  {
    "nguyenvukhang/nvim-toggler",
    config = function()
      require("nvim-toggler").setup()
    end
  },

  -- Render Markdown
  {
    "MeanderingProgrammer/render-markdown.nvim",
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          vim.keymap.set("n", "<leader>m", function()
            require("render-markdown").toggle()
          end, { desc = "Toggle Markdown Render" })
        end,
      })
    end
  },

  -- Zen Mode
  {
    "folke/zen-mode.nvim",
    config = function()
      require("zen-mode").setup({
        window = {
          width = 0.75,
          options = {
            signcolumn = "no",
            number = false,
            relativenumber = false,
            cursorline = false,
            foldcolumn = "0",
            list = false,
          },
        },
        plugins = { gitsigns = { enabled = false }, tmux = { enabled = false }, kitty = { enabled = false }, twilight = { enabled = false } },
      })
    end
  },

  -- Biscuits  
  'code-biscuits/nvim-biscuits',
})

-- ======================
-- Plugin Configuration
-- ======================

-- Everforest theme 🌲
pcall(function()
  vim.g.everforest_background = 'soft'      -- soft green
  vim.g.everforest_enable_italic = true
  vim.g.everforest_diagnostic_line_highlight = 1
  vim.g.everforest_better_performance = 1
  vim.g.everforest_transparent_background = 1
  vim.cmd.colorscheme("everforest")
end)

-- Dashboard (Alpha)
pcall(function()
  local alpha = require("alpha")
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
    [[                                 everforest neovim                              ]],
  }

  dashboard.section.buttons.val = {
    dashboard.button("e", "  New file", ":ene <BAR> startinsert<CR>"),
    dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
    dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
    dashboard.button("l", "󰒲  Plugins", ":Lazy<CR>"),
    dashboard.button("q", "  Quit NVIM", ":qa<CR>"),
  }

  alpha.setup(dashboard.opts)
end)

-- Neo-tree
pcall(function()
  require("neo-tree").setup({})
  vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "File Explorer" })
  vim.keymap.set("n", "<S-M-h>", ":Neotree reveal ~/dotfiles<CR>", { desc = "Open dotfiles" })
end)

-- Telescope
pcall(function()
  require("telescope").setup({})
end)

-- Lualine (Everforest)
pcall(function()
  require("lualine").setup({
    options = {
      theme = "everforest",
      section_separators = '',
      component_separators = ''
    }
  })
end)

-- Noice
pcall(function()
  require("noice").setup({ lsp = { progress = { enabled = false } }, presets = { command_palette = true } })
end)

-- Treesitter
pcall(function()
  require("nvim-treesitter.configs").setup({
    highlight = { enable = true },
    indent = { enable = true }
  })
end)

-- nvim biscuits
require('nvim-biscuits').setup({
  toggle_keybind = "<leader>b",
  show_on_start = true
})

