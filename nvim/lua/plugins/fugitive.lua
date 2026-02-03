return {
    {
        "tpope/vim-fugitive",
        name = "fugitive",
        config = function()
            -- load the colorscheme here
            vim.keymap.set("n", "<F10>", ":Git blame<cr>")
        end,
    }
}
