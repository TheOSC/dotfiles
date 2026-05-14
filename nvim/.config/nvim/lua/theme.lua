-- =============================================================================
-- theme.lua
-- Reads wallust color cache and applies as colorscheme
-- Falls back to a bundled dark theme if cache not present
-- =============================================================================

local M = {}

-- Path to wallust color cache
local cache_path = vim.fn.expand("~/.cache/wallust/colors.json")

-- =============================================================================
-- READ WALLUST COLORS
-- =============================================================================
local function read_wallust_colors()
    local file = io.open(cache_path, "r")
    if not file then return nil end
    local content = file:read("*a")
    file:close()

    -- Parse JSON manually (no external deps)
    -- wallust colors.json format:
    -- { "colors": { "color0": "#xxxxxx", ... }, "special": { "background": ... } }
    local colors = {}
    for key, value in content:gmatch('"(color%d+)"%s*:%s*"(#%x+)"') do
        colors[key] = value
    end
    for key, value in content:gmatch('"(background|foreground|cursor)"%s*:%s*"(#%x+)"') do
        colors[key] = value
    end

    -- Also try flat format
    if not colors.background then
        for key, value in content:gmatch('"(%w+)"%s*:%s*"(#%x+)"') do
            colors[key] = value
        end
    end

    return colors
end

-- =============================================================================
-- APPLY COLORS
-- =============================================================================
local function apply_colors(c)
    if not c then return end

    local bg   = c.background or c.color0  or "#1a1a1a"
    local fg   = c.foreground or c.color7  or "#d0d0d0"
    local acc  = c.color4                  or "#5f8aab"
    local acc2 = c.color2                  or "#7a9e7e"
    local surf = c.color8                  or "#373b41"
    local red  = c.color1                  or "#cc6666"
    local yel  = c.color3                  or "#de935f"
    local cyn  = c.color6                  or "#5e8d87"

    -- Set highlight groups
    local hi = vim.api.nvim_set_hl

    -- Base
    hi(0, "Normal",       { fg = fg,   bg = bg })
    hi(0, "NormalFloat",  { fg = fg,   bg = surf })
    hi(0, "NormalNC",     { fg = fg,   bg = bg })

    -- Cursor
    hi(0, "Cursor",       { fg = bg,   bg = fg })
    hi(0, "CursorLine",   { bg = surf })
    hi(0, "CursorLineNr", { fg = acc,  bold = true })
    hi(0, "LineNr",       { fg = surf })

    -- Selection
    hi(0, "Visual",       { bg = acc,  fg = bg })
    hi(0, "VisualNOS",    { bg = acc,  fg = bg })

    -- Search
    hi(0, "Search",       { fg = bg,   bg = yel })
    hi(0, "IncSearch",    { fg = bg,   bg = acc })
    hi(0, "CurSearch",    { fg = bg,   bg = acc })

    -- Statusline
    hi(0, "StatusLine",   { fg = fg,   bg = surf })
    hi(0, "StatusLineNC", { fg = surf, bg = bg })

    -- Splits
    hi(0, "VertSplit",    { fg = surf })
    hi(0, "WinSeparator", { fg = surf })

    -- Completion menu
    hi(0, "Pmenu",        { fg = fg,   bg = surf })
    hi(0, "PmenuSel",     { fg = bg,   bg = acc })
    hi(0, "PmenuSbar",    { bg = surf })
    hi(0, "PmenuThumb",   { bg = acc })

    -- Diagnostics
    hi(0, "DiagnosticError", { fg = red })
    hi(0, "DiagnosticWarn",  { fg = yel })
    hi(0, "DiagnosticInfo",  { fg = acc })
    hi(0, "DiagnosticHint",  { fg = cyn })

    -- Syntax
    hi(0, "Comment",     { fg = surf, italic = true })
    hi(0, "String",      { fg = acc2 })
    hi(0, "Number",      { fg = yel })
    hi(0, "Boolean",     { fg = red })
    hi(0, "Function",    { fg = acc,  bold = true })
    hi(0, "Keyword",     { fg = red,  bold = true })
    hi(0, "Type",        { fg = yel })
    hi(0, "Identifier",  { fg = fg })
    hi(0, "Operator",    { fg = cyn })
    hi(0, "Delimiter",   { fg = fg })
    hi(0, "Special",     { fg = acc2 })

    -- Diff
    hi(0, "DiffAdd",     { fg = acc2, bg = bg })
    hi(0, "DiffChange",  { fg = yel,  bg = bg })
    hi(0, "DiffDelete",  { fg = red,  bg = bg })
    hi(0, "DiffText",    { fg = acc,  bg = bg })

    -- Git signs
    hi(0, "GitSignsAdd",    { fg = acc2 })
    hi(0, "GitSignsChange", { fg = yel })
    hi(0, "GitSignsDelete", { fg = red })

    -- Telescope
    hi(0, "TelescopeBorder",         { fg = acc })
    hi(0, "TelescopePromptBorder",   { fg = acc })
    hi(0, "TelescopeResultsBorder",  { fg = surf })
    hi(0, "TelescopePreviewBorder",  { fg = surf })
    hi(0, "TelescopeSelection",      { fg = fg, bg = surf })
    hi(0, "TelescopeMatching",       { fg = acc, bold = true })

    -- Which-key
    hi(0, "WhichKey",      { fg = acc })
    hi(0, "WhichKeyGroup", { fg = acc2 })
    hi(0, "WhichKeyDesc",  { fg = fg })
end

-- =============================================================================
-- INIT
-- =============================================================================
function M.setup()
    vim.o.background = "dark"
    vim.cmd("highlight clear")
    if vim.fn.exists("syntax_on") then
        vim.cmd("syntax reset")
    end

    local colors = read_wallust_colors()
    apply_colors(colors)

    -- Re-apply on colorscheme change (e.g. after wallust regenerates)
    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
            local fresh = read_wallust_colors()
            apply_colors(fresh)
        end,
    })
end

M.setup()

return M
