local function open_nvim_tree()
    require("nvim-tree.api").tree.open()
end

return {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    init = function()
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
    end,
    config = function()
        -- Desativa nvim-autopairs neste buffer
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "NvimTree",
            callback = function()
                vim.b.nvim_autopairs_disable = true
            end,
        })

        require("nvim-tree").setup({
            on_attach = function(bufnr)
                local api = require("nvim-tree.api")

                local function opts(desc)
                    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                end

                api.config.mappings.default_on_attach(bufnr)

                -- Custom mappings (tree stays open, focus moves to file)
                vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
                vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
                vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
                vim.keymap.set("n", "s", api.node.open.horizontal, opts("Open: Horizontal Split"))
            end,

            -- IntelliJ-style: sync tree with open file
            sync_root_with_cwd = true,
            respect_buf_cwd = true,
            update_focused_file = {
                enable = true,
                update_root = false,
            },

            view = {
                width = {
                    min = 30,
                    max = 50,
                    padding = 1,
                },
                side = "left",
                signcolumn = "no",
            },

            actions = {
                open_file = {
                    quit_on_open = false,
                    window_picker = { enable = false },
                },
            },

            renderer = {
                group_empty = true,
                root_folder_label = ":t",  -- show only project folder name (like IntelliJ)
                indent_width = 2,
                indent_markers = {
                    enable = true,
                    icons = {
                        corner = "└",
                        edge = "│",
                        item = "│",
                        bottom = "─",
                        none = " ",
                    },
                },
                icons = {
                    git_placement = "after",  -- git status after filename (cleaner)
                    diagnostics_placement = "before",  -- inline icons instead of signcolumn (avoids E155 on nvim 0.12)
                    show = {
                        file = true,
                        folder = true,
                        folder_arrow = true,
                        git = true,
                        modified = true,
                        diagnostics = true,
                    },
                    glyphs = {
                        default = "",
                        symlink = "",
                        modified = "●",
                        folder = {
                            arrow_closed = "▸",
                            arrow_open = "▾",
                            default = "",
                            open = "",
                            empty = "",
                            empty_open = "",
                            symlink = "",
                            symlink_open = "",
                        },
                        git = {
                            unstaged = "M",
                            staged = "A",
                            unmerged = "U",
                            renamed = "R",
                            untracked = "?",
                            deleted = "D",
                            ignored = "◌",
                        },
                    },
                },
                special_files = {},  -- no special file highlighting (IntelliJ doesn't do this)
            },

            filters = {
                dotfiles = false,
                custom = { "^.git$" },
            },

            git = {
                enable = true,
                ignore = false,
            },

            diagnostics = {
                enable = true,
                show_on_dirs = true,
                icons = {
                    hint = "",
                    info = "",
                    warning = "",
                    error = "",
                },
            },

            modified = {
                enable = true,
                show_on_dirs = true,
            },
        })

        -- IntelliJ-style highlight overrides for the tree panel
        local function set_tree_highlights()
            local hl = vim.api.nvim_set_hl
            -- Subtle sidebar background (slightly different from editor)
            hl(0, "NvimTreeNormal", { link = "Normal" })
            hl(0, "NvimTreeEndOfBuffer", { link = "Normal" })
            -- Clean folder styling
            hl(0, "NvimTreeFolderName", { bold = true })
            hl(0, "NvimTreeOpenedFolderName", { bold = true })
            hl(0, "NvimTreeEmptyFolderName", { bold = true })
            -- Subtle indent markers
            hl(0, "NvimTreeIndentMarker", { fg = "#555555" })
            -- Git colors (IntelliJ-like: muted blue/green/red)
            hl(0, "NvimTreeGitNew", { fg = "#6A8759" })      -- green for new
            hl(0, "NvimTreeGitDirty", { fg = "#6897BB" })    -- blue for modified
            hl(0, "NvimTreeGitDeleted", { fg = "#CC7832" })   -- orange for deleted
            hl(0, "NvimTreeGitStaged", { fg = "#6A8759" })    -- green for staged
        end
        set_tree_highlights()
        -- Reapply after colorscheme changes
        vim.api.nvim_create_autocmd("ColorScheme", { callback = set_tree_highlights })

        -- Keymap para toggle
        vim.keymap.set("n", "<leader>e", function()
            local api = require("nvim-tree.api")
            if api.tree.is_visible() then
                api.tree.close()
            else
                open_nvim_tree()
            end
        end, { desc = "Toggle file explorer" })
    end,
}
