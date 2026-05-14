-- =============================================================================
-- options.lua
-- Core neovim settings
-- =============================================================================

local opt = vim.opt

-- =============================================================================
-- APPEARANCE
-- =============================================================================
opt.termguicolors   = true          -- True color support
opt.number          = true          -- Line numbers
opt.relativenumber  = true          -- Relative line numbers
opt.cursorline      = true          -- Highlight current line
opt.signcolumn      = "yes"         -- Always show sign column
opt.showmode        = false         -- Don't show mode (statusline handles it)
opt.wrap            = false         -- No line wrap
opt.scrolloff       = 8             -- Keep 8 lines above/below cursor
opt.sidescrolloff   = 8             -- Keep 8 cols left/right of cursor
opt.colorcolumn     = "80"          -- Column guide at 80 chars
opt.list            = true          -- Show invisible characters
opt.listchars       = {
    tab   = "→ ",
    trail = "·",
    nbsp  = "␣",
}

-- =============================================================================
-- EDITING
-- =============================================================================
opt.tabstop         = 4             -- Tab width
opt.shiftwidth      = 4             -- Indent width
opt.softtabstop     = 4
opt.expandtab       = true          -- Spaces instead of tabs
opt.smartindent     = true          -- Smart auto-indent
opt.autoindent      = true

opt.ignorecase      = true          -- Case insensitive search
opt.smartcase       = true          -- Unless uppercase used
opt.incsearch       = true          -- Incremental search
opt.hlsearch        = true          -- Highlight search results

opt.undofile        = true          -- Persistent undo
opt.undodir         = vim.fn.expand("~/.local/state/nvim/undo")

opt.swapfile        = false         -- No swap files
opt.backup          = false         -- No backup files
opt.writebackup     = false

opt.clipboard       = "unnamedplus" -- Use system clipboard
opt.mouse           = "a"           -- Enable mouse

-- =============================================================================
-- UI
-- =============================================================================
opt.splitright      = true          -- Vertical splits open right
opt.splitbelow      = true          -- Horizontal splits open below
opt.pumheight       = 10            -- Completion popup max height
opt.pumblend        = 10            -- Completion popup transparency
opt.winblend        = 0
opt.laststatus      = 3             -- Global statusline
opt.cmdheight       = 1
opt.updatetime      = 250           -- Faster completion
opt.timeoutlen      = 300           -- Key sequence timeout

-- =============================================================================
-- COMPLETION
-- =============================================================================
opt.completeopt     = { "menuone", "noselect", "noinsert" }
opt.shortmess:append("c")

-- =============================================================================
-- PERFORMANCE
-- =============================================================================
opt.lazyredraw      = false         -- Don't use with animations
opt.synmaxcol       = 300           -- Don't syntax highlight very long lines

-- =============================================================================
-- ENSURE DIRS EXIST
-- =============================================================================
vim.fn.mkdir(vim.fn.expand("~/.local/state/nvim/undo"), "p")
