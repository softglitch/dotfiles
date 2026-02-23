local util = require("lspconfig/util")

local root = vim.fn.system("git rev-parse --show-toplevel")
root = root:gsub("%s+$", "")
local venv = vim.fn.system("pushd " .. root .. "/tests/.venv")
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


vim.lsp.config('lua_ls', {
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" },
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
            telemetry = {
                enable = false,
            },
        },
    },
})
