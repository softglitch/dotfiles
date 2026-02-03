require("config.lazy")
require("config.lsp")
require("config.telescope")
require("config.wrap_popup")
require("config.catppuccin")

--require("config.cmp")
-- copilot shit
vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
    expr = true,
    replace_keycodes = false
})
vim.g.copilot_no_tab_map = true

-- binds
vim.g.mapleader = " "
-- because nvim devs suck (https://github.com/neovim/neovim/issues/416)
vim.keymap.set("n", "Y", "Y")
-- go back to last buffer
vim.keymap.set("n", "<tab>", ":b#<cr>")
-- robot shit
vim.keymap.set("i", "<C-space>", "<space><space><space><space>")
vim.keymap.set("n", "<leader>rj", ":RobotJump ")
vim.keymap.set("n", "<leader>cc", ":CopilotChat<CR>")

vim.keymap.set("n", "gt", ":RobotJump ", { desc = "Jumping to test" })
vim.keymap.set("n", "grr", ":RobotRun<CR>")
vim.keymap.set("n", "grt", ":RobotRunTest<CR>")
vim.keymap.set("n", "gry", ":RobotRunTag<CR>")
vim.keymap.set({"n", "t"}, "gT", "<cmd>RobotToggle<CR>", { desc = "Toggle Robot Runner" })

vim.keymap.set("n", "<leader>r", ":w<CR>:!robotidy %:p<CR>:e! %<CR><cr>")
vim.keymap.set("n", "<leader>c", ":w<CR>:!robocop format %:p<CR>:e! %<CR><cr>")
vim.keymap.set("n", "<leader>j", ":%!python3 -m json.tool<CR>")
vim.keymap.set("n", "<C-p>", ":!black %<cr><cr>")
vim.keymap.set("n", "<leader><space>", ":nohlsearch<CR>")

-- reload current file
vim.keymap.set("n", "<leader><S-r>", ":e! %<CR>")

-- line numbers
vim.opt.nu = true
vim.opt.relativenumber = true

-- tabs
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false

-- assosiate dump files as log files
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = { "dump", "*.dump", "*.out", "*.log.*", "dump.*" },
    command = ":set filetype=log"
})

-- teach nvim how robot does comments
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = { "*.resource", "*.robot" },
    command = ":setlocal commentstring=#\\ %s"
})

-- swap sux
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = "/tmp/nvim_undodir"
vim.opt.undofile = true

-- search
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true

-- ehh...
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")
vim.opt.updatetime = 50
vim.opt.colorcolumn = ""

vim.cmd("hi clear statuslinenc")

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = { "*" },
    command = [[%s/\s\+$//e]],
})


-- Set default options for LSP floating windows
local border = "rounded"

-- Apply the border to all LSP hover/signature floats
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover,
    { border = border }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help,
    { border = border }
)

-- Optional: also apply to diagnostics
vim.diagnostic.config({
    float = { border = border },
})

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function()
        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
            vim.lsp.handlers.hover, { border = border }
        )
        vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
            vim.lsp.handlers.signature_help, { border = border }
        )
    end,
})

do
    local orig = vim.lsp.util.open_floating_preview
    function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or "rounded"
        return orig(contents, syntax, opts, ...)
    end
end
-- Helper to make border tables
local function border(hl)
    return {
        { "╭", hl }, { "─", hl }, { "╮", hl }, { "│", hl },
        { "╯", hl }, { "─", hl }, { "╰", hl }, { "│", hl },
    }
end

-- Diagnostics border
local orig_diag = vim.diagnostic.open_float
vim.diagnostic.open_float = function(bufnr, opts)
    opts = opts or {}
    opts.border = opts.border or border("FloatBorderDiagnostic")
    return orig_diag(bufnr, opts)
end

-- Hover border
vim.lsp.handlers["textDocument/hover"] =
    vim.lsp.with(vim.lsp.handlers.hover, { border = border("FloatBorderHover") })

-- Signature help border
vim.lsp.handlers["textDocument/signatureHelp"] =
    vim.lsp.with(vim.lsp.handlers.signature_help, { border = border("FloatBorderSignature") })

vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf",
    callback = function()
        vim.opt_local.winfixheight = true
        vim.cmd("resize 10")
    end,
})

vim.keymap.set("n", "<leader>q", function()
    local wins = vim.fn.getwininfo()
    for _, w in ipairs(wins) do
        if w.quickfix == 1 then
            vim.cmd("cclose")
            return
        end
    end
    vim.cmd("copen")
end, { desc = "Toggle quickfix window" })


-- vim.diagnostic.config({
--     virtual_text = { severity = { min = vim.diagnostic.severity.HINT } },
--     signs = true,
--     underline = true,
-- })

-- Bughunting and ops stuff, once you’ve gotten the hang of things.
-- The only “new” info you ever learn about a production system is that it is broken or,
-- even worse, that it is somehow managing to deliver value despite having the software equivalent
-- of hyperdimensional aggressive bone cancer.
-- Instead of merely not affording chances to learn or explore, this work actively punishes
-- you for digging into the abyss.
--
