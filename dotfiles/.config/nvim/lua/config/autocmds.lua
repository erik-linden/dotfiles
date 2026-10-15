local group = vim.api.nvim_create_augroup("user_config", { clear = true })

-- Delete trailing whitespace and trailing blank lines on save
vim.api.nvim_create_autocmd("BufWritePre", {
    group = group,
    callback = function()
        if vim.bo.binary or vim.bo.filetype == "diff" then
            return
        end
        local view = vim.fn.winsaveview()
        vim.cmd([[keeppatterns silent! %s/\s\+$//e]])
        vim.cmd([[keeppatterns silent! %s/\n\+\%$//e]])
        vim.fn.winrestview(view)
    end,
})

-- Briefly highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    group = group,
    callback = function()
        (vim.hl or vim.highlight).on_yank({ timeout = 200 })
    end,
})

-- Open files at the last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
    group = group,
    callback = function(args)
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        local lines = vim.api.nvim_buf_line_count(args.buf)
        if mark[1] > 0 and mark[1] <= lines and vim.bo[args.buf].filetype ~= "gitcommit" then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Reload files changed outside of nvim when coming back to it
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
    group = group,
    command = "silent! checktime",
})

-- Equalize splits when the terminal (i3 window) is resized
vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    command = "wincmd =",
})
