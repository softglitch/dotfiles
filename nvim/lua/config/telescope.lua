local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>f", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>g", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>b", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>h", builtin.help_tags, { desc = "Telescope help tags" })
vim.keymap.set("n", "<leader>M", builtin.diagnostics, { desc = "Telescope diagnostics" })
-- diagnostics for the current buffer
vim.keymap.set("n", "<leader>m", function()
    local diagnostics = vim.diagnostic.get(0)
    if #diagnostics == 0 then
        vim.notify("No diagnostics in current buffer", vim.log.levels.INFO)
        return
    end

    vim.fn.setqflist(vim.diagnostic.toqflist(diagnostics), "r")
    require("telescope.builtin").quickfix({
        prompt_title = "Diagnostics (current buffer)",
        initial_mode = "normal",
    })
end, { desc = "Telescope diagnostics (current buffer only)" })

require("telescope").setup({
    defaults = {
        -- this affects all pickers unless overridden below
        layout_strategy = "center", -- center the popup
        layout_config = {
            anchor = "N",
        },
        sorting_strategy = "descending",
        winblend = 20,
    },

    pickers = {
        live_grep = {
            theme = "dropdown",
            hidden = true,
            follow = true,
            layout_config = { width = 0.75, height = 0.5 },
        },
        find_files = {
            theme = "dropdown",
            hidden = true,
            follow = true,
            layout_config = { width = 0.75, height = 0.5 },
        },
    },
})
