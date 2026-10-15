-- Git signs in the sign column. Replaces vim-gitgutter from .vimrc.

return {
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            on_attach = function(buf)
                local gs = require("gitsigns")
                local function map(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
                end
                -- Same as vim-gitgutter. In diff mode ]c/[c keep their built-in meaning.
                map("n", "]c", function()
                    if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else gs.nav_hunk("next") end
                end, "Next git hunk")
                map("n", "[c", function()
                    if vim.wo.diff then vim.cmd.normal({ "[c", bang = true }) else gs.nav_hunk("prev") end
                end, "Previous git hunk")
                map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
                map("n", "<leader>gs", gs.stage_hunk, "Stage/unstage hunk")
                map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
                map("n", "<leader>gb", gs.blame_line, "Blame line")
                map("n", "<leader>gB", gs.blame, "Blame file")
                map("n", "<leader>gd", gs.diffthis, "Diff against index")
                map({ "o", "x" }, "ih", gs.select_hunk, "Hunk")
            end,
        },
    },
}
