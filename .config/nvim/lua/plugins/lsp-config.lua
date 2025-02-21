return {
    {
        "williamboman/mason.nvim",
        lazy = false,
        build = ":MasonUpdate",
        config = function()
            require("mason").setup({
                ui = {
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗"
                    }
                }
            })
        end
    },
    {
        "williamboman/mason-lspconfig.nvim",
        lazy = false,
        dependencies = {
            "williamboman/mason.nvim"
        },
        config = function()
            require("mason-lspconfig").setup({
                auto_install = true,
                ensure_installed = {
                    "lua_ls",
                    "ts_ls",
                    "solargraph",
                    "html",
                    "cssmodules_ls",
                    "ruby_lsp",
                    "phpactor"
                }
            })
        end
    },
    {
        "neovim/nvim-lspconfig",
        lazy = false,
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            local lspconfig = require("lspconfig")

            lspconfig.ts_ls.setup({
                capabilities = capabilities
            })

            lspconfig.solargraph.setup({
                capabilities = capabilities
            })

            lspconfig.html.setup({
                capabilities = capabilities
            })

            lspconfig.lua_ls.setup({
                capabilities = capabilities
            })

            lspconfig.phpactor.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                init_options = {
                    ["language_server_phpstan.enabled"] = false,
                    ["language_server_psalm.enabled"] = false,
                }
            })

            lspconfig.cssmodules_ls.setup({
                capabilities = capabilities
            })

            lspconfig.ruby_lsp.setup({
                capabilities = capabilities,
                formatter = 'standard',
                linters = {'standard'}
            })

            -- LSP Keymaps
            vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
            vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
            vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {})
        end,
    },
}
