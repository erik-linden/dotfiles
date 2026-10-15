-- Look and feel.
-- Replaces from .vimrc: gruvbox-material (kept), vim-airline -> lualine,
-- nerdtree -> nvim-tree, vim-css-color -> nvim-highlight-colors.

return {
    {
        "sainnhe/gruvbox-material",
        lazy = false,
        priority = 1000,
        config = function()
            vim.g.gruvbox_material_background = "hard"
            vim.g.gruvbox_material_better_performance = 1
            vim.g.gruvbox_material_enable_italic = 1
            vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
            vim.cmd.colorscheme("gruvbox-material")
        end,
    },

    -- File icons (needs a Nerd Font)
    { "nvim-tree/nvim-web-devicons", lazy = true },

    -- Status line
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        opts = {
            options = {
                theme = "gruvbox-material",
                globalstatus = false,
            },
            sections = {
                lualine_c = { { "filename", path = 1 } },
                lualine_x = { "diagnostics", "filetype" },
            },
        },
    },

    -- File tree
    {
        "nvim-tree/nvim-tree.lua",
        cmd = { "NvimTreeToggle", "NvimTreeFindFile" },
        keys = {
            { "<C-n>", "<cmd>NvimTreeToggle<cr>", desc = "File tree" },
            { "<leader>t", "<cmd>NvimTreeFindFile<cr>", desc = "Show file in tree" },
        },
        opts = {
            view = { width = 35 },
            renderer = { group_empty = true },
            filters = { dotfiles = false, git_ignored = false },
            -- Press g? in the tree for help
        },
    },

    -- Show colors like #d8a657 in their color
    {
        "brenoprata10/nvim-highlight-colors",
        event = { "BufReadPost", "BufNewFile" },
        opts = { render = "background", enable_named_colors = false },
    },

    -- Shows pending key bindings, e.g. press <leader> and wait
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "classic",
            spec = {
                { "<leader>g", group = "git" },
                { "<leader>s", group = "search" },
            },
        },
    },
}
