-- Treesitter parsers to install. Also used by scripts/fetch-offline-bundle.sh.
return {
    "bash", "c", "cmake", "cpp", "diff", "dockerfile", "fish", "git_config",
    "gitcommit", "gitignore", "html", "ini", "json", "lua", "make", "markdown",
    "markdown_inline", "python", "query", "regex", "rust", "starlark",
    "toml", "vim", "vimdoc", "xml", "yaml",
    -- Needed by xml. Listed so the offline bundle includes its source too.
    "dtd",
}
