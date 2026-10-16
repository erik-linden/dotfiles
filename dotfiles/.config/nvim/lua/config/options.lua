-- Editor settings. Things that are already Neovim defaults are left out
-- (e.g. autoread, hlsearch, incsearch, autoindent, mouse=a).

local opt = vim.opt

-- Not needed, and avoids :checkhealth warnings
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- nvim-tree replaces netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

opt.termguicolors = true
opt.background = "dark"

opt.updatetime = 100        -- More frequent updates (git signs, diagnostics)
opt.number = true           -- Show line numbers
opt.cursorline = true       -- Highlight the current line
opt.showmatch = true        -- Highlight matching bracket pairs
opt.scrolloff = 1           -- Always show at least one line above/below the cursor
opt.signcolumn = "yes"      -- Always show the sign column, so text doesn't jump
opt.list = true             -- Show tabs and trailing whitespace
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

opt.spell = true            -- Spell checking (only comments/strings in code with treesitter)
opt.spelllang = "en"
opt.spelloptions = "camel"  -- Check each part of camelCase words
-- Words added with zg go into the dotfiles (copy_to_repo.py picks them up)
local spelldir = vim.fn.stdpath("config") .. "/spell"
vim.fn.mkdir(spelldir, "p")
local spellfile = spelldir .. "/en.utf-8.add"
-- nvim only reads the compiled en.utf-8.add.spl next to it, which isn't in
-- the dotfiles (binary). Build it when it's missing or older than the word
-- list (before setting 'spellfile', so this session already uses it).
local add = vim.uv.fs_stat(spellfile)
local spl = vim.uv.fs_stat(spellfile .. ".spl")
if add and (not spl or spl.mtime.sec < add.mtime.sec) then
    vim.cmd("silent! mkspell! " .. vim.fn.fnameescape(spellfile))
end
opt.spellfile = spellfile

opt.ignorecase = true       -- Ignore case when searching
opt.smartcase = true        -- Case-sensitive if caps in query
opt.inccommand = "split"    -- Live preview of :s substitutions
-- :grep uses ripgrep, respecting .gitignore (the default also searches ignored files)
if vim.fn.executable("rg") == 1 then
    opt.grepprg = "rg --vimgrep --smart-case"
end

opt.tabstop = 4             -- 4 whitespaces for tab presentation
opt.shiftwidth = 4          -- Shift lines by 4 spaces
opt.expandtab = true        -- Expand tabs into spaces

opt.clipboard = "unnamedplus" -- Use system clipboard

opt.backup = false          -- Disable backups
opt.writebackup = false
opt.swapfile = false
opt.undofile = true         -- Persistent undo, survives closing the file

opt.splitbelow = true       -- More natural split opening
opt.splitright = true

opt.confirm = true          -- Ask instead of failing on :q with unsaved changes
