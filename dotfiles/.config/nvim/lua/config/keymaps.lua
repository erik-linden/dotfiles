-- Key mappings not tied to a plugin. Plugin mappings live with the plugin in
-- lua/plugins/. Overview of all bindings: docs/keybindings.md.
-- Leader is "," (set in init.lua).

local map = vim.keymap.set

-- Save with <leader>w
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save" })

-- System clipboard (normal yank/delete/paste don't touch it, see options.lua)
map({ "n", "x" }, "<leader>y", '"+y', { desc = "Copy to system clipboard" })
map("n", "<leader>Y", '"+y$', { desc = "Copy to end of line to system clipboard" })
map({ "n", "x" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })
map({ "n", "x" }, "<leader>P", '"+P', { desc = "Paste from system clipboard, before cursor" })

-- Additional escape mapping (same in fish)
map("i", "jk", "<Esc>")

-- Map 0 to the first non-blank character and + to the last
map({ "n", "x", "o" }, "0", "^")
map({ "n", "x", "o" }, "+", "$")

-- Map <Space> to search and Ctrl-<Space> to backwards search
map({ "n", "x" }, "<Space>", "/")
map({ "n", "x" }, "<C-Space>", "?")

-- Disable search highlighting
map("n", "<leader><CR>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "<Esc>", "<cmd>nohlsearch<cr><Esc>")

-- Splits use the same letters as i3 (Alt+i / Alt+n) and tmux (Ctrl+a i / n):
-- i = new window beside (:vsplit), n = new window below (:split).
-- Built in and also shared: <C-w>h/j/k/l focus, <C-w>q close.
map("n", "<C-w>i", "<cmd>vsplit<cr>", { desc = "Split: new window beside" })
map("n", "<C-w>n", "<cmd>split<cr>", { desc = "Split: new window below" })

-- Jump between splits (shortcut for <C-w>h etc.)
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Keep the selection when indenting
map("x", "<", "<gv")
map("x", ">", ">gv")

-- Diagnostics (Neovim also has [d ]d to jump, <C-w>d to show)
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to location list" })

-- LSP: Neovim 0.11 defaults are
--   K hover, grn rename, gra code action, grr references, gri implementation,
--   gO document symbols, <C-s> signature help (insert mode)
-- Extra mappings, for muscle memory:
map("n", "<F3>", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "<F4>", vim.lsp.buf.hover, { desc = "Documentation" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
