-- =============================================================================
-- plugins.lua
-- Plugin management via lazy.nvim
-- Installs lazy.nvim automatically if not present
-- =============================================================================

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- =============================================================================
-- PLUGINS
-- =============================================================================
require("lazy").setup({

    -- -------------------------------------------------------------------------
    -- UI
    -- -------------------------------------------------------------------------

    -- File tree
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup({
                view = { width = 30 },
                renderer = {
                    group_empty = true,
                    icons = { show = { git = true } },
                },
                filters = { dotfiles = false },
            })
            vim.keymap.set("n", "<leader>t",
                "<cmd>NvimTreeToggle<CR>",
                { noremap = true, silent = true })
        end,
    },

    -- Status line
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = {
                    theme = "auto",
                    component_separators = { left = "", right = "" },
                    section_separators   = { left = "", right = "" },
                    globalstatus = true,
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = { { "filename", path = 1 } },
                    lualine_x = { "encoding", "fileformat", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
            })
        end,
    },

    -- Buffer tabs
    {
        "akinsho/bufferline.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("bufferline").setup({
                options = {
                    mode = "buffers",
                    separator_style = "slant",
                    show_buffer_close_icons = true,
                    show_close_icon = false,
                    diagnostics = "nvim_lsp",
                },
            })
        end,
    },

    -- Indent guides
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        config = function()
            require("ibl").setup({
                indent = { char = "│" },
                scope  = { enabled = true },
            })
        end,
    },

    -- -------------------------------------------------------------------------
    -- TELESCOPE — fuzzy finder
    -- -------------------------------------------------------------------------
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
            },
        },
        config = function()
            require("telescope").setup({
                defaults = {
                    layout_strategy = "horizontal",
                    sorting_strategy = "ascending",
                    layout_config = {
                        prompt_position = "top",
                    },
                },
            })
            require("telescope").load_extension("fzf")
        end,
    },

    -- -------------------------------------------------------------------------
    -- TREESITTER — syntax highlighting
    -- -------------------------------------------------------------------------
    {
        "nvim-treesitter/nvim-treesitter",
	enabled = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "lua", "bash", "python", "javascript",
                    "typescript", "json", "yaml", "toml",
                    "markdown", "css", "html", "vim", "vimdoc",
                },
                highlight    = { enable = true },
                indent       = { enable = true },
                auto_install = true,
            })
        end,
    },

    -- -------------------------------------------------------------------------
    -- LSP
    -- -------------------------------------------------------------------------
    {
        "neovim/nvim-lspconfig",
	enabled = false,
        dependencies = {
            "williamboman/mason.nvim",
	    enabled = false,
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "bashls", "pyright" },
                automatic_installation = true,
            })

            local lspconfig = require("lspconfig")
            local on_attach = function(_, bufnr)
                local opts = { buffer = bufnr, noremap = true, silent = true }
                vim.keymap.set("n", "gd",          vim.lsp.buf.definition,      opts)
                vim.keymap.set("n", "gD",          vim.lsp.buf.declaration,     opts)
                vim.keymap.set("n", "gr",          vim.lsp.buf.references,      opts)
                vim.keymap.set("n", "K",           vim.lsp.buf.hover,           opts)
                vim.keymap.set("n", "<leader>rn",  vim.lsp.buf.rename,          opts)
                vim.keymap.set("n", "<leader>ca",  vim.lsp.buf.code_action,     opts)
                vim.keymap.set("n", "<leader>f",   vim.lsp.buf.format,          opts)
            end

            lspconfig.lua_ls.setup({ on_attach = on_attach })
            lspconfig.bashls.setup({ on_attach = on_attach })
            lspconfig.pyright.setup({ on_attach = on_attach })
        end,
    },

    -- -------------------------------------------------------------------------
    -- COMPLETION
    -- -------------------------------------------------------------------------
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp     = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"]     = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"]     = cmp.mapping.abort(),
                    ["<CR>"]      = cmp.mapping.confirm({ select = false }),
                    ["<Tab>"]     = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                }),
            })
        end,
    },

    -- -------------------------------------------------------------------------
    -- GIT
    -- -------------------------------------------------------------------------
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                signs = {
                    add          = { text = "│" },
                    change       = { text = "│" },
                    delete       = { text = "󰍵" },
                    topdelete    = { text = "‾" },
                    changedelete = { text = "~" },
                },
                current_line_blame = true,
                current_line_blame_opts = {
                    delay = 500,
                },
            })
        end,
    },

    -- -------------------------------------------------------------------------
    -- EDITING QUALITY OF LIFE
    -- -------------------------------------------------------------------------

    -- Auto pairs
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({
                check_ts = true,
            })
            -- Integrate with cmp
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end,
    },

    -- Comments
    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
        end,
    },

    -- Surround
    {
        "kylechui/nvim-surround",
        config = function()
            require("nvim-surround").setup()
        end,
    },

    -- Highlight todo comments
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("todo-comments").setup()
        end,
    },

    -- Which-key — shows available keybinds
    {
        "folke/which-key.nvim",
        config = function()
            require("which-key").setup()
        end,
    },

}, {
    -- lazy.nvim options
    ui = {
        border = "rounded",
    },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip", "matchit", "matchparen",
                "netrwPlugin", "tarPlugin", "tohtml",
                "tutor", "zipPlugin",
            },
        },
    },
})
