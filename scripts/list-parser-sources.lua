-- Used by fetch-offline-bundle.sh: writes "<language> <git url> <revision>"
-- for each parser in lua/config/parsers.lua to the file in $PARSER_LIST,
-- using the versions nvim-treesitter has pinned.
-- Run with: nvim --headless "+luafile scripts/list-parser-sources.lua" +qa

local parsers = require("nvim-treesitter.parsers")
local lines = {}
for _, lang in ipairs(require("config.parsers")) do
    local info = parsers[lang] and parsers[lang].install_info
    if info and info.url and info.revision then
        table.insert(lines, table.concat({ lang, info.url, info.revision }, " "))
    else
        io.stderr:write("No download information for parser: " .. lang .. "\n")
    end
end
vim.fn.writefile(lines, os.getenv("PARSER_LIST"))
