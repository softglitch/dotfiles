return {
    {
        "catppuccin/nvim",
        lazy = false,
        name = "catppuccin",
        priority = 1000,
        config = function(_, opts)
        -- config = function()
          -- load the colorscheme here
          -- vim.cmd([[colorscheme catppuccin]])
          require("catppuccin").setup(opts)
          vim.cmd.colorscheme("catppuccin")
          require("config.catcolors")
-- end,
        end,
    }
}
