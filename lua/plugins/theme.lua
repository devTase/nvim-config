-- Available themes to cycle through
local themes = { "darcula-solid", "rose-pine", "tokyonight", "habamax" }
local current_theme_idx = 1

-- IntelliJ Darcula exact colors applied over treesitter highlights
local function apply_intellij_highlights()
    local hl = vim.api.nvim_set_hl
    local orange    = "#CC7832"   -- keywords
    local green     = "#6A8759"   -- strings
    local blue      = "#6897BB"   -- numbers, constants
    local gray      = "#808080"   -- comments
    local yellow    = "#FFC66D"   -- function/method declarations
    local purple    = "#9876AA"   -- fields, parameters, type params
    local anno_yel  = "#BBB529"   -- annotations
    local text      = "#A9B7C6"   -- default text
    local white     = "#FFFFFF"   -- class/type names in IntelliJ are brighter

    -- Keywords (public, class, static, void, return, if, for, etc.)
    hl(0, "@keyword",              { fg = orange, bold = false })
    hl(0, "@keyword.modifier",     { fg = orange })  -- public, private, static, final
    hl(0, "@keyword.type",         { fg = orange })  -- class, interface, enum
    hl(0, "@keyword.return",       { fg = orange })
    hl(0, "@keyword.import",       { fg = orange })  -- import
    hl(0, "@keyword.operator",     { fg = orange })  -- new, instanceof
    hl(0, "@keyword.exception",    { fg = orange })  -- throw, try, catch
    hl(0, "@keyword.conditional",  { fg = orange })  -- if, else, switch
    hl(0, "@keyword.repeat",       { fg = orange })  -- for, while
    hl(0, "@keyword.function",     { fg = orange })  -- function keyword (other langs)
    hl(0, "@keyword.storage",      { fg = orange })
    hl(0, "Keyword",               { fg = orange })
    hl(0, "Statement",             { fg = orange })
    hl(0, "Conditional",           { fg = orange })
    hl(0, "Repeat",                { fg = orange })
    hl(0, "Exception",             { fg = orange })
    hl(0, "StorageClass",          { fg = orange })

    -- Types / classes
    hl(0, "@type",                 { fg = white })
    hl(0, "@type.builtin",         { fg = orange })  -- int, boolean, void
    hl(0, "@type.qualifier",       { fg = orange })  -- final, volatile
    hl(0, "Type",                  { fg = white })

    -- Functions / methods
    hl(0, "@function",             { fg = yellow })
    hl(0, "@function.call",        { fg = text })
    hl(0, "@function.method",      { fg = yellow })
    hl(0, "@function.method.call", { fg = text })
    hl(0, "Function",              { fg = yellow })

    -- Variables & fields
    hl(0, "@variable",             { fg = text })
    hl(0, "@variable.member",      { fg = purple })   -- fields
    hl(0, "@variable.parameter",   { fg = text })
    hl(0, "@variable.builtin",     { fg = orange })   -- this, super

    -- Constants
    hl(0, "@constant",             { fg = purple, italic = true })
    hl(0, "@constant.builtin",     { fg = orange })   -- null, true, false
    hl(0, "Constant",              { fg = purple, italic = true })
    hl(0, "Boolean",               { fg = orange })

    -- Strings
    hl(0, "@string",               { fg = green })
    hl(0, "@string.escape",        { fg = orange })
    hl(0, "String",                { fg = green })

    -- Numbers
    hl(0, "@number",               { fg = blue })
    hl(0, "@number.float",         { fg = blue })
    hl(0, "Number",                { fg = blue })
    hl(0, "Float",                 { fg = blue })

    -- Comments
    hl(0, "@comment",              { fg = gray, italic = true })
    hl(0, "Comment",               { fg = gray, italic = true })

    -- Annotations (@Override, @Test, etc.)
    hl(0, "@attribute",            { fg = anno_yel })
    hl(0, "PreProc",               { fg = anno_yel })

    -- Operators & punctuation
    hl(0, "@operator",             { fg = text })
    hl(0, "@punctuation.bracket",  { fg = text })
    hl(0, "@punctuation.delimiter",{ fg = text })
    hl(0, "Operator",              { fg = text })
end

function ColorMyPencils(color)
    color = color or "darcula-solid"
    vim.cmd.colorscheme(color)

    if color == "darcula-solid" then
        apply_intellij_highlights()
    else
        vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    end
end

-- Cycle themes with <leader>th
vim.keymap.set("n", "<leader>th", function()
    current_theme_idx = current_theme_idx % #themes + 1
    local theme = themes[current_theme_idx]
    ColorMyPencils(theme)
    vim.notify("Theme: " .. theme, vim.log.levels.INFO)
end, { desc = "Cycle colorscheme" })

return {
    {
        "briones-gabriel/darcula-solid.nvim",
        dependencies = { "rktjmp/lush.nvim" },
        priority = 1000,
        config = function()
            vim.cmd("colorscheme darcula-solid")
            ColorMyPencils("darcula-solid")
        end,
    },
    {
        "folke/tokyonight.nvim",
        config = function()
            require("tokyonight").setup({
                style = "storm",
                transparent = true,
                terminal_colors = true,
                styles = {
                    comments = { italic = false },
                    keywords = { italic = false },
                    sidebars = "dark",
                    floats = "dark",
                },
            })
        end,
    },
    {
        "rose-pine/neovim",
        name = "rose-pine",
        config = function()
            require("rose-pine").setup({
                disable_background = true,
                styles = {
                    italic = false,
                },
            })
        end,
    },
}