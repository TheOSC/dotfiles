-- =============================================================================
-- keymaps.lua
-- Neovim keybindings
-- =============================================================================

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Leader key
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- =============================================================================
-- GENERAL
-- =============================================================================

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>", opts)

-- Save
map("n", "<C-s>", "<cmd>w<CR>", opts)
map("i", "<C-s>", "<Esc><cmd>w<CR>", opts)

-- Quit
map("n", "<leader>q", "<cmd>q<CR>", opts)
map("n", "<leader>Q", "<cmd>qa!<CR>", opts)

-- =============================================================================
-- NAVIGATION
-- =============================================================================

-- Move between windows
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- Resize windows
map("n", "<C-Up>",    "<cmd>resize +2<CR>", opts)
map("n", "<C-Down>",  "<cmd>resize -2<CR>", opts)
map("n", "<C-Left>",  "<cmd>vertical resize -2<CR>", opts)
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", opts)

-- Better up/down on wrapped lines
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz", opts)
map("n", "<C-u>", "<C-u>zz", opts)

-- Keep search results centered
map("n", "n", "nzzzv", opts)
map("n", "N", "Nzzzv", opts)

-- =============================================================================
-- BUFFERS
-- =============================================================================
map("n", "<leader>bn", "<cmd>bnext<CR>",     opts)
map("n", "<leader>bp", "<cmd>bprevious<CR>", opts)
map("n", "<leader>bd", "<cmd>bdelete<CR>",   opts)
map("n", "<Tab>",      "<cmd>bnext<CR>",     opts)
map("n", "<S-Tab>",    "<cmd>bprevious<CR>", opts)

-- =============================================================================
-- EDITING
-- =============================================================================

-- Indent and stay in visual mode
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- Move lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", opts)
map("v", "K", ":m '<-2<CR>gv=gv", opts)

-- Don't overwrite clipboard when pasting over selection
map("v", "p", '"_dP', opts)

-- Delete without yanking
map("n", "<leader>d", '"_d', opts)
map("v", "<leader>d", '"_d', opts)

-- =============================================================================
-- SPLITS
-- =============================================================================
map("n", "<leader>sv", "<cmd>vsplit<CR>", opts)
map("n", "<leader>sh", "<cmd>split<CR>",  opts)
map("n", "<leader>sc", "<cmd>close<CR>",  opts)

-- =============================================================================
-- TELESCOPE (file finding, grep — loaded by plugins.lua)
-- =============================================================================
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>",  opts)
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>",   opts)
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>",     opts)
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>",   opts)
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>",    opts)

-- =============================================================================
-- LSP (set up in plugins.lua, keymaps registered on attach)
-- =============================================================================
map("n", "<leader>e",  vim.diagnostic.open_float, opts)
map("n", "[d",         vim.diagnostic.goto_prev,  opts)
map("n", "]d",         vim.diagnostic.goto_next,  opts)
