-- === :CatColors — Catppuccin palette viewer ===============================
-- Usage:
--   :CatColors           -> uses current catppuccin flavour (or mocha)
--   :CatColors mocha     -> show mocha palette (latte|frappe|macchiato|mocha)
-- Keys:
--   q / <Esc>            -> close
--   y                    -> yank hex under cursor to + register
--   <CR>                 -> yank "name hex" to + register

local function open_cat_colors(flavour)
    -- Resolve flavour: prefer current theme's, else user arg, else mocha
    local current = nil
    pcall(function() current = require("catppuccin").options and require("catppuccin").options.flavour end)
    flavour = flavour or current or "mocha"

    local ok_pal, palettes = pcall(require, "catppuccin.palettes")
    if not ok_pal then
        vim.notify("catppuccin not found", vim.log.levels.ERROR)
        return
    end
    local p = palettes.get_palette(flavour)
    if not p then
        vim.notify("Unknown catppuccin flavour: " .. tostring(flavour), vim.log.levels.WARN)
        return
    end

    -- Prepare lines (sorted)
    local names = {}
    for k in pairs(p) do table.insert(names, k) end
    table.sort(names)

    local lines = {}
    for _, name in ipairs(names) do
        local hex = p[name]
        table.insert(lines, string.format("%-11s %s  ██████", name, hex))
    end

    -- Create buffer & window
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_option(buf, "filetype", "catcolors")

    local ui    = vim.api.nvim_list_uis()[1]
    local width = 28
    for _, s in ipairs(lines) do width = math.max(width, #s + 2) end
    local height = math.min(#lines + 2, math.max(10, math.floor(ui.height * 0.7)))
    local row    = math.floor((ui.height - height) / 2)
    local col    = math.floor((ui.width - width) / 2)

    local title  = (" Catppuccin · %s "):format(flavour)
    local win    = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        row = row,
        col = col,
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
        title = title,
        title_pos = "center",
        noautocmd = true,
    })
    vim.api.nvim_win_set_option(win, "winhl", "NormalFloat:NormalFloat,FloatBorder:FloatBorder")

    -- Add per-line highlights (fg swatch text + block)
    for i, name in ipairs(names) do
        local hex = p[name]
        local hl  = "CatColor_" .. name
        vim.api.nvim_set_hl(0, hl, { fg = hex })

        -- color the "hex" and the block at end of line
        local line = lines[i]
        local hex_start = line:find("#")
        if hex_start then
            vim.api.nvim_buf_add_highlight(buf, -1, hl, i - 1, hex_start - 1, hex_start - 1 + 7) -- #RRGGBB
        end
        -- color the ██████ (last 6 chars)
        vim.api.nvim_buf_add_highlight(buf, -1, hl, i - 1, #line - 6, #line)
    end

    -- Keymaps (buffer-local)
    local function close()
        if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
    end
    vim.keymap.set("n", "q", close, { buffer = buf, nowait = true })
    vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true })

    -- Yank HEX
    vim.keymap.set("n", "y", function()
        local line = vim.api.nvim_get_current_line()
        local hex = line:match("#%x%x%x%x%x%x")
        if hex then
            vim.fn.setreg("+", hex)
            vim.notify("Yanked " .. hex .. " to clipboard", vim.log.levels.INFO, { title = "CatColors" })
        end
    end, { buffer = buf })

    -- Yank "name hex"
    vim.keymap.set("n", "<CR>", function()
        local line = vim.api.nvim_get_current_line()
        local name, hex = line:match("^(%S+)%s+(#%x%x%x%x%x%x)")
        if name and hex then
            local s = name .. " " .. hex
            vim.fn.setreg("+", s)
            vim.notify('Yanked "' .. s .. '"', vim.log.levels.INFO, { title = "CatColors" })
        end
    end, { buffer = buf })
end

vim.api.nvim_create_user_command("CatColors", function(opts)
    local flav = opts.args ~= "" and opts.args or nil
    open_cat_colors(flav)
end, {
    nargs = "?",
    complete = function() return { "latte", "frappe", "macchiato", "mocha" } end,
})
-- ========================================================================
