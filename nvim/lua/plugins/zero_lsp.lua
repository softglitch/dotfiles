return {
    {
        'williamboman/mason.nvim',
        lazy = false,
        opts = {},
    },

    -- in lua/plugins/luasnip.lua (or inside your cmp plugin spec)
    {
        "L3MON4D3/LuaSnip",
        version = "v2.*",                -- or "v2.*" / "v1.*" depending on your cfg
        build = "make install_jsregexp", -- optional but recommended
        dependencies = {
            "rafamadriz/friendly-snippets",
        },
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
        end,
    },

    -- Autocompletion
    {
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        config = function()
            local cmp = require('cmp')

            cmp.setup({
                sources = {
                    { name = 'nvim_lsp' },
                    { name = 'buffer' },
                },
                completion = { completeopt = "menu,menuone,noselect" }, -- recommended
                mapping = cmp.mapping.preset.insert({
                    ["<C-n>"] = cmp.mapping.select_next_item(),
                    ["<C-p>"] = cmp.mapping.select_prev_item(),
                    ["<CR>"]  = cmp.mapping.confirm({
                        select = true,                         -- accept first item if none selected
                        behavior = cmp.ConfirmBehavior.Insert, -- replace the typed prefix
                    }),
                    -- (alt) ["<C-y>"] = cmp.mapping.confirm({ select = true }),
                }),
                snippet = {
                    expand = function(args) require("luasnip").lsp_expand(args.body) end,
                },
            })
            -- cmp.setup({
            --     sources = {
            --         { name = 'nvim_lsp' },
            --         { name = 'buffer' },
            --     },
            --     mapping = cmp.mapping.preset.insert({
            --         ['<C-n>'] = cmp.mapping.complete(),
            --         ['<C-u>'] = cmp.mapping.scroll_docs(-4),
            --         ['<C-d>'] = cmp.mapping.scroll_docs(4),
            --         ['<CR>'] = nil
            --         -- ['<CR>'] = cmp.mapping.confirm({
            --         --     behavior = cmp.ConfirmBehavior.Replace,
            --         --     select = true
            --         -- }),
            --     }),
            --     snippet = {
            --         expand = function(args)
            --             vim.snippet.expand(args.body)
            --         end,
            --     },
            -- })
        end
    },

    -- LSP
    {
        'neovim/nvim-lspconfig',
        cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
        event = { 'BufReadPre', 'BufNewFile' },
        dependencies = {
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'williamboman/mason.nvim' },
            { 'williamboman/mason-lspconfig.nvim' },
        },
        init = function()
            -- Reserve a space in the gutter
            -- This will avoid an annoying layout shift in the screen
            vim.opt.signcolumn = 'yes'
        end,
        config = function()
            local lsp_defaults = require('lspconfig').util.default_config

            -- Add cmp_nvim_lsp capabilities settings to lspconfig
            -- This should be executed before you configure any language server
            lsp_defaults.capabilities = vim.tbl_deep_extend(
                'force',
                lsp_defaults.capabilities,
                require('cmp_nvim_lsp').default_capabilities()
            )

            -- LspAttach is where you enable features that only work
            -- if there is a language server active in the file
            vim.api.nvim_create_autocmd('LspAttach', {
                desc = 'LSP actions',
                callback = function(event)
                    local opts = { buffer = event.buf }
                    local border = "rounded"
                    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
                        vim.lsp.handlers.hover, { border = border }
                    )
                    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
                        vim.lsp.handlers.signature_help, { border = border }
                    )

                    --vim.keymap.set('i', '<c-x>', '<cmd>lua require("cmp").mapping.complete()<cr>', opts)
                    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
                    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
                    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
                    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
                    vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
                    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
                    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
                    vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
                    vim.keymap.set('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
                    vim.keymap.set({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
                    vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
                    vim.keymap.set({ 'n', 'x' }, 'gq', function()
                        vim.lsp.buf.format({ async = true })
                    end, opts)
                end,
            })

            require('mason-lspconfig').setup({
                ensure_installed = {},
                handlers = {
                    -- this first function is the "default handler"
                    -- it applies to every language server without a "custom handler"
                    function(server_name)
                        require('lspconfig')[server_name].setup({})
                    end,
                }
            })
        end
    }
}
