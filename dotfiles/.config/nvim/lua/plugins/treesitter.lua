-- Better syntax highlighting, and spell checking limited to comments/strings.
-- Parsers are compiled C code, installed to ~/.local/share/nvim/site/parser.
-- Building them needs the tree-sitter program and a C compiler (see
-- docs/SETUP.md). Without them, nvim falls back to regex highlighting.
-- The list of parsers is in lua/config/parsers.lua.
-- Show installed parsers: :checkhealth nvim-treesitter
--
-- Offline machines: install-bundle.sh puts the parsers' source code in
-- ~/.local/share/nvim/parser-sources/<language>. When that folder exists,
-- parsers are built from it instead of being downloaded.

local source_dir = vim.fn.stdpath("data") .. "/parser-sources"

-- Point each parser that has local sources at them. Called by
-- nvim-treesitter (User TSUpdate) whenever it (re)loads its parser list.
local function use_local_sources()
    local parsers = require("nvim-treesitter.parsers")
    for _, lang in ipairs(require("config.parsers")) do
        local info = parsers[lang] and parsers[lang].install_info
        local dir = source_dir .. "/" .. lang
        if info and vim.uv.fs_stat(dir) then
            -- Keep the other settings (e.g. which subfolder to build)
            info.path = dir
            info.url = nil
        end
    end
end

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            -- gcc with -Wall (always added by `tree-sitter build`) needs
            -- ~4.7 GB of RAM for the gitcommit parser, enough to freeze a
            -- small machine; without this warning ~0.5 GB. HOST_CFLAGS is
            -- read by tree-sitter's build (Rust's cc crate) but not by make
            -- or configure, so builds started from nvim's terminal keep
            -- their own CFLAGS.
            vim.env.HOST_CFLAGS = vim.trim((vim.env.HOST_CFLAGS or "") .. " -Wno-uninitialized")

            if vim.uv.fs_stat(source_dir) then
                -- Applied now, and again whenever nvim-treesitter reloads
                -- its parser list
                vim.api.nvim_create_autocmd("User", {
                    pattern = "TSUpdate",
                    callback = function() pcall(use_local_sources) end,
                })
                pcall(use_local_sources)
            end

            -- Needs tree-sitter and a C compiler; without them, nvim would
            -- try (and fail) again at every start
            if vim.fn.executable("tree-sitter") == 1 and vim.fn.executable("cc") == 1 then
                -- Only installs what is missing; runs in the background
                require("nvim-treesitter").install(require("config.parsers"))
            end

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
                callback = function(args)
                    -- Does nothing if there is no parser for the filetype
                    pcall(vim.treesitter.start, args.buf)
                end,
            })
        end,
    },
}
