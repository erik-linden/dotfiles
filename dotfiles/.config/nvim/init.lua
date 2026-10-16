-- Neovim configuration. Needs Neovim 0.11 or newer (Ubuntu 24.04 apt has 0.9,
-- which is too old, see docs/SETUP.md for how to install a newer one).
--
-- Layout:
--   lua/config/options.lua   editor settings
--   lua/config/keymaps.lua   key mappings not tied to a plugin
--   lua/config/autocmds.lua  automatic actions (trim whitespace on save etc.)
--   lua/config/lazy.lua      plugin manager bootstrap
--   lua/plugins/*.lua        one file per area, each returns plugin specs
--
-- Useful commands: :Lazy (plugins), :checkhealth, :LspInfo, :ConformInfo,
-- <leader> then wait, to see all leader mappings.

-- Must be set before plugins load
vim.g.mapleader = ","
vim.g.maplocalleader = ","

require("config.options")
require("config.keymaps")
require("config.autocmds")

if vim.fn.has("nvim-0.11") == 1 then
    require("config.lazy")
else
    vim.notify("Neovim 0.11+ needed for plugins, running without them", vim.log.levels.WARN)
    vim.cmd.colorscheme("habamax")
end
