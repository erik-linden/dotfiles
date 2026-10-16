-- Fuzzy finding.
-- Uses the fzf binary on $PATH (needs fzf 0.36+, see docs/SETUP.md) and
-- ripgrep for searching file contents.
-- Inside the picker: <C-j>/<C-k> or arrows to move, <Tab> to multi-select,
-- <F1> for help (lists all picker keys).

return {
    {
        "ibhagwan/fzf-lua",
        cmd = "FzfLua",
        keys = {
            { "<C-p>", "<cmd>FzfLua files<cr>", desc = "Find files" },
            { "<leader>sf", "<cmd>FzfLua files<cr>", desc = "Files" },
            { "<leader>sg", "<cmd>FzfLua live_grep<cr>", desc = "Grep (live)" },
            { "<leader>sw", "<cmd>FzfLua grep_cword<cr>", desc = "Word under cursor" },
            { "<leader>sb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
            { "<leader>sr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
            { "<leader>sh", "<cmd>FzfLua helptags<cr>", desc = "Help" },
            { "<leader>sk", "<cmd>FzfLua keymaps<cr>", desc = "Key mappings" },
            { "<leader>ss", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Symbols (file)" },
            { "<leader>sS", "<cmd>FzfLua lsp_live_workspace_symbols<cr>", desc = "Symbols (project)" },
            { "<leader>sd", "<cmd>FzfLua diagnostics_document<cr>", desc = "Diagnostics" },
            { "<leader>s.", "<cmd>FzfLua resume<cr>", desc = "Resume last search" },
            { "<leader>/", "<cmd>FzfLua blines<cr>", desc = "Search in buffer" },
        },
        opts = {
            fzf_colors = true, -- Take colors from the colorscheme
            winopts = { preview = { layout = "flex" } },
        },
    },
}
