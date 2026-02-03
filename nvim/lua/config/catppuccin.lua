require("catppuccin").setup({
    -- pick your flavour: "latte", "frappe", "macchiato", "mocha"
    flavour = "mocha",

    -- Make float borders clearly visible
    custom_highlights = function(colors)
        local c = colors
        return {
            NormalFloat             = { bg = c.surface0 },              -- float background
            FloatBorder             = { fg = c.pink, bg = c.surface0 }, -- float border
            -- Optional: match diagnostic popups too
            DiagnosticFloatingError = { link = "DiagnosticError" },
            DiagnosticFloatingWarn  = { link = "DiagnosticWarn" },
            DiagnosticFloatingInfo  = { link = "DiagnosticInfo" },
            DiagnosticFloatingHint  = { link = "DiagnosticHint" },
            WrapForward             = { fg = c.teal, bg = c.base },
            WrapBackward            = { fg = c.sky, bg = c.base },
            DiagWrapForward         = { fg = c.rosewater, bg = c.base },
            DiagWrapBackward        = { fg = c.flamingo, bg = c.base },
            WrapError               = { fg = c.red, bg = c.base },
        }
    end,
})
vim.cmd.colorscheme("catppuccin")
