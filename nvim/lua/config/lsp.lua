-- local lspconfig = require("lspconfig")
local util = require("lspconfig/util")

local root = vim.fn.system("git rev-parse --show-toplevel")
root = root:gsub("%s+$", "")
local venv = vim.fn.system("pushd " .. root .. "/tests && pipenv --venv")
    -- vim.fn.expand("~") .. "/robotframework-lsp/robocorp-python-ls-core/src/",
    -- vim.fn.expand("~") .. "/robotframework-lsp/robotframework-ls/src/",
venv = venv:gsub("%s+$", "")
local pythonpath = {
    venv .. "/lib/python3.12/site-packages/",
    root .. "/tests/libraries/",
    root .. "/tests/resources/",
    root .. "/tests/",
}


vim.lsp.config('pylsp', {
    plugins = {
        black = {
            enabled = true,
        },
        mypy = {
            enabled = true,
            live_mode = true,
        },
    },
})


vim.lsp.config('robotframework_ls', {
    -- on_attach = function(client, bufnr)
    --     print(pythonpath[1])
    -- end,
    settings = {
        robot = {
            pythonpath = pythonpath,
            variables = {
                EXECDIR = root .. "/tests",
            },
            loadVariablesFromArgumentsFile = root .. "/.lsp.resource",
            lint = {
                keywordResolvesToMultipleKeywords = false,
                robocop = {
                    enabled = true,
                },
            },
            libraries = {
                libdoc = {
                    -- needsArgs = { "common.imclient", "terminals.py" },
                    needsArgs = { "libraries.libtimefaker", "common.imclient", "common.libdcid", "terminals.py" },
                },
            },
        },
    },
})


vim.lsp.config('clangd', {
    cmd = { "clangd", "--background-index", "--suggest-missing-includes", "--clang-tidy", "--header-insertion=never", "--compile-commands-dir=" .. root .. "/builddir" },
    filetypes = { "h", "c", "cpp", "objc", "objcpp" },
    root_dir = util.root_pattern("compile_commands.json", ".git"),
    -- settings = {
    --     clangd = {
    --         semanticHighlighting = true,
    --         completion = {
    --             filterAndSort = true,
    --         },
    --         diagnostics = {
    --             disabled = { "clang-diagnostic-unused-parameter" },
    --         },
    --     },
    -- },
})


vim.lsp.config('bashls', {
    filetypes = { "sh", "bash", "zsh" },
    settings = {
        bashIde = {
            shellcehckPath = vim.fn.exepath("shellcheck"),

        },
    },
})

vim.lsp.config('xmlformatter', {
    filetypes = { "xml" },
})

--RobotCode LSP
-- vim.lsp.config('robotcode', {
--     root_markers = { ".git" },
--     filetypes = { "robot", "resource" },
--     -- root_markers = { ".robocop" },
--     -- cmd = { "robotcode", "language-server" },

--     settings = {
--         robotcode = {
--             analysis = {
--                 findUnusedReferences = true,
--                 diagnosticMode       = "openFilesOnly", -- or "workspace"
--                 progressMode         = "detailed",
--                 cache                = {
--                     saveLocation = "workspaceFolder",
--                     enabled = true,
--                 },
--             },
--             robocop ={
--                 enabled = true,
--                 configFile = root .. "/.robocop",
--             },
--             robot = {
--                 pythonPath = pythonpath,
--                 variables = {
--                     EXECDIR = root .. "/tests",
--                 },
--                 args = {
--                     "-A", root .. "/.lsp.resource",
--                 },
--                 -- you can add more later:
--                 -- outputDir = "./results",
--                 paths = { "robot" },
--             },
--         },
--     },
-- })
-- vim.api.nvim_create_autocmd("FileType", {
--     pattern = { "robot", "resource" },
--     callback = function(ev)
--         -- vim.lsp.set_log_level('debug')
--         vim.lsp.enable("robotcode", {
--             bufnr = ev.buf,
--         })
--     end,
-- })

