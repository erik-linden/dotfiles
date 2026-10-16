-- Plugin manager: https://lazy.folke.io
-- Plugins are installed to ~/.local/share/nvim/lazy. Exact versions are
-- pinned in ~/.config/nvim/lazy-lock.json (keep it in the dotfiles repo).
--
-- With internet, plugins are installed on the first start. Without internet,
-- the offline bundle brings them (see docs/SETUP.md).

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    local out = vim.fn.system({
        "git", "clone", "--filter=blob:none", "--branch=stable",
        "https://github.com/folke/lazy.nvim.git", lazypath,
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to install lazy.nvim (offline?), running without plugins.\n", "WarningMsg" },
            { "See docs/SETUP.md for offline installs.\n" },
            { out },
        }, true, {})
        vim.cmd.colorscheme("habamax")
        return
    end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = { { import = "plugins" } },
    -- Colorscheme used while installing plugins
    install = { colorscheme = { "gruvbox-material", "habamax" } },
    -- Update only when asked (:Lazy update), not in the background
    checker = { enabled = false },
    change_detection = { notify = false },
    rocks = { enabled = false },
    performance = {
        rtp = {
            disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
        },
    },
})
