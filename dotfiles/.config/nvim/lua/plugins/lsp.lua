-- Language servers, formatting and completion.
--
-- The servers are separate programs, install them with uv (see docs/SETUP.md):
--   uv tool install ruff           linting, formatting, import sorting
--   uv tool install basedpyright   completion, go to definition, type checking
-- Check status with :checkhealth vim.lsp

-- Python servers look for the project's environment in these places
local python_envs = { "/.venv/bin/python", "/.pixi/envs/default/bin/python" }

return {
    -- Default server configs (cmd, filetypes, root markers) for vim.lsp.enable
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            vim.diagnostic.config({
                severity_sort = true,
                -- Like ALE: only show the message for the line the cursor is on
                virtual_text = { current_line = true },
                underline = true,
                float = { border = "rounded", source = true },
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "󰅚",
                        [vim.diagnostic.severity.WARN] = "󰀪",
                        [vim.diagnostic.severity.INFO] = "󰋽",
                        [vim.diagnostic.severity.HINT] = "󰌶",
                    },
                },
            })

            vim.lsp.config("basedpyright", {
                settings = {
                    basedpyright = {
                        -- ruff sorts imports
                        disableOrganizeImports = true,
                        -- "recommended" (the default) is very strict
                        analysis = { typeCheckingMode = "standard" },
                    },
                },
                -- Use the project's .venv or pixi environment if there is one
                on_init = function(client)
                    local root = client.root_dir
                    if not root then
                        return
                    end
                    for _, env in ipairs(python_envs) do
                        if vim.uv.fs_stat(root .. env) then
                            client.config.settings.python = { pythonPath = root .. env }
                            client:notify("workspace/didChangeConfiguration", { settings = client.config.settings })
                            return
                        end
                    end
                end,
            })

            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("user_lsp", { clear = true }),
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    -- basedpyright gives better hover documentation than ruff
                    if client and client.name == "ruff" then
                        client.server_capabilities.hoverProvider = false
                    end
                end,
            })

            -- Only enable servers that are installed
            for _, server in ipairs({ "ruff", "basedpyright" }) do
                local cmd = vim.lsp.config[server] and vim.lsp.config[server].cmd
                if type(cmd) == "table" and vim.fn.executable(cmd[1]) == 1 then
                    vim.lsp.enable(server)
                end
            end
        end,
    },

    -- Formatting, <leader>f (was :ALEFix)
    {
        "stevearc/conform.nvim",
        cmd = "ConformInfo",
        keys = {
            {
                "<leader>f",
                function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
                mode = { "n", "x" },
                desc = "Format (ruff fix + format)",
            },
        },
        opts = {
            formatters_by_ft = {
                python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
                lua = { "stylua", lsp_format = "fallback" },
            },
        },
    },

    -- Completion popup (was YouCompleteMe). Tab/Shift-Tab cycle like YCM,
    -- Enter or C-y accepts, C-e closes, C-space opens.
    {
        "saghen/blink.cmp",
        -- A release version downloads a prebuilt fuzzy matcher
        version = "1.*",
        event = "InsertEnter",
        opts = {
            keymap = {
                preset = "default",
                ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
                ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
                ["<CR>"] = { "accept", "fallback" },
            },
            completion = {
                list = { selection = { preselect = false, auto_insert = true } },
                documentation = { auto_show = true, auto_show_delay_ms = 300 },
            },
            signature = { enabled = true },
            sources = { default = { "lsp", "path", "buffer" } },
            appearance = { nerd_font_variant = "mono" },
            -- Falls back to a slower Lua matcher if the prebuilt one is missing
            fuzzy = { implementation = "prefer_rust" },
        },
    },
}
