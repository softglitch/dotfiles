return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup {
                ensure_installed = { "python", "robot", "css", "html", "javascript", "cpp", "c", "vim", "regex", "lua", "bash", "markdown", "markdown_inline" },
                auto_install = true,
                highlight = {
                    enable = true,
                    disable = { "robot", "vim" },
                },
            }
        end
    }
}
