local function open_nvim_tree()
    require("nvim-tree.api").tree.open()  -- abre como buffer normal, sem float
end

return {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    init = function()
        -- disable netrw at the very start of your init.lua
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

                -- Custom mappings
                vim.keymap.set("n", "<CR>", function()
                    local node = api.tree.get_node_under_cursor()
                    if node.type == "directory" then
                        api.node.open.edit(node)
                    else
                        api.node.open.edit(node)
                        api.tree.close()
                    end
                end, opts("Open/Close"))

                vim.keymap.set("n", "o", function()
                    local node = api.tree.get_node_under_cursor()
                    if node.type == "directory" then
                        api.node.open.edit(node)
                    else
                        api.node.open.edit(node)
                        api.tree.close()
                    end
                end, opts("Open/Close"))

                vim.keymap.set("n", "v", function()
                    local node = api.tree.get_node_under_cursor()
                    api.node.open.vertical(node)
                    api.tree.close()
                end, opts("Open: Vertical Split"))

                vim.keymap.set("n", "s", function()
                    local node = api.tree.get_node_under_cursor()
                    api.node.open.horizontal(node)
                    api.tree.close()
                end, opts("Open: Horizontal Split"))
            end,

            view = {
                width = {
                    min = 30,
                    max = 50,
                    padding = 1
                },
            },

            actions = {
                open_file = {
                    quit_on_open = false,  -- mantém o buffer aberto
                    window_picker = { enable = false },
                },
            },

            renderer = {
                group_empty = true,
                icons = {
                    show = {
                        file = true,
                        folder = true,
                        folder_arrow = true,
                        git = true,
                    },
                },
            },
        })

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
