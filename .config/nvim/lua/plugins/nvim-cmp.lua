local M = {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "saadparwaiz1/cmp_luasnip",
        "L3MON4D3/LuaSnip",
        "rafamadriz/friendly-snippets"
    }
}

M.config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    -- Load snippets from VSCode-style snippet sources
    require("luasnip.loaders.from_vscode").lazy_load()

    -- Custom completion menu highlighting
    vim.cmd([[
        " Ensure selection is clearly visible
        highlight! CmpItemAbbrMatch guifg=#569CD6 gui=bold
        highlight! CmpItemAbbrMatchFuzzy guifg=#569CD6 gui=bold
        highlight! CmpItemMenu guifg=#808080 gui=italic
        
        " Customize selection highlight
        highlight! CmpItemSelectShadow guibg=#2C3244
        highlight! link CmpItemSelect PmenuSel
    ]])

    -- Custom border style with improved visibility
    local border_style = {
        border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
        winhighlight = "Normal:CmpPmenu,CursorLine:CmpItemSelect,Search:None"
    }

    cmp.setup({
        completion = {
            completeopt = 'menu,menuone,noinsert'
        },

        -- Enhanced window configuration
        window = {
            completion = cmp.config.window.bordered({
                border = border_style.border,
                winhighlight = "Normal:CmpPmenu,CursorLine:CmpItemSelect"
            }),
            documentation = cmp.config.window.bordered({
                border = border_style.border,
                winhighlight = "Normal:CmpDocNormal,FloatBorder:CmpDocBorder"
            })
        },

        snippet = {
            expand = function(args)
                luasnip.lsp_expand(args.body)
            end,
        },

        mapping = {
            ['<CR>'] = cmp.mapping({
                i = function(fallback)
                    if cmp.visible() and cmp.get_active_entry() then
                        cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
                    else
                        fallback()
                    end
                end,
                s = cmp.mapping.confirm({ select = true }),
                c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
            }),
            
            ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_next_item({behavior = cmp.SelectBehavior.Select})
                elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                else
                    fallback()
                end
            end, { "i", "s" }),
            
            ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item({behavior = cmp.SelectBehavior.Select})
                elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end, { "i", "s" }),
        },

        sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "nvim_lua" },
            { name = "luasnip" },
        }, {
            { name = "buffer", keyword_length = 4 },
            { name = "path" },
        }),

        -- Formatting of completion items
        formatting = {
            format = function(entry, vim_item)
                -- Customize the appearance of completion items
                vim_item.menu = ({
                    nvim_lsp = "[LSP]",
                    nvim_lua = "[Lua]",
                    luasnip = "[Snippet]",
                    buffer = "[Buffer]",
                    path = "[Path]",
                })[entry.source.name]
                
                return vim_item
            end
        },

        -- Experimental: improve selection visibility
        experimental = {
            ghost_text = true
        }
    })

    -- Command-line completion setup
    cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
            { name = "path" },
        }, {
            { name = "cmdline" },
        }),
    })

    -- Configure signature help (for function argument hints)
    vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
        vim.lsp.handlers.signature_help, 
        {
            border = "rounded",
            max_width = 80,
            max_height = 30,
            winhighlight = "Normal:CmpDocNormal,FloatBorder:CmpDocBorder"
        }
    )

    -- Additional LuaSnip configuration
    luasnip.config.set_config({
        history = true,
        updateevents = "TextChanged,TextChangedI",
        enable_autosnippets = true,
    })
end

return M
