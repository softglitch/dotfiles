-- ── Add/replace in lua/config/wrap_popup.lua ──────────────────────────────
-- Highlight groups (tweak or put into Catppuccin custom_highlights)
vim.api.nvim_set_hl(0, "WrapForward", { link = "WarningMsg" })
vim.api.nvim_set_hl(0, "WrapBackward", { link = "Title" })
vim.api.nvim_set_hl(0, "DiagWrapForward", { link = "DiagnosticWarn" })
vim.api.nvim_set_hl(0, "DiagWrapBackward", { link = "DiagnosticInfo" })
vim.api.nvim_set_hl(0, "WrapError", { link = "ErrorMsg" })

-- Centered popup with centered text (multi-line safe)
local function show_wrap_popup(msg, hl_group)
    local lines = vim.split(msg, "\n", { plain = true })

    -- display width helper (handles UTF-8 / emojis)
    local function dwidth(s) return vim.fn.strdisplaywidth(s) end
    local maxw = 0
    for _, l in ipairs(lines) do
        maxw = math.max(maxw, dwidth(l))
    end

    -- pad each line so text is centered within the popup box
    local padded = {}
    for _, l in ipairs(lines) do
        local pad_total = math.max(0, maxw - dwidth(l))
        local left = math.floor(pad_total / 2)
        local right = pad_total - left
        table.insert(padded, string.rep(" ", left+1) .. l .. string.rep(" ", right-1))
    end

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, padded)

    local ui     = vim.api.nvim_list_uis()[1]
    local width  = maxw + 2 -- small side padding
    local height = #padded
    local row    = math.floor((ui.height - height) / 2)
    local col    = math.floor((ui.width - width) / 2)

    local win    = vim.api.nvim_open_win(buf, false, {
        relative = "editor",
        row = row,
        col = col,
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
        noautocmd = true,
    })

    local hl     = hl_group or "WrapForward"
    vim.api.nvim_win_set_option(win, "winhl", "NormalFloat:" .. hl .. ",FloatBorder:" .. hl)

    -- keep visible for 1.1s
    vim.defer_fn(function()
        if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
        if hl_group == "WrapError" then
            vim.cmd("set hlsearch")
        end
    end, 1100)
end

local function will_wrap_search(go_same_dir)
    local pat = vim.fn.getreg("/")
    if pat == "" then return "no_pattern", true end

    -- Will there be ANY match (allow wrap)?
    local any = vim.fn.searchpos(pat, "n") -- "n" = no move, allow wrap
    if any[1] == 0 then return "no_match", true end

    local forward = vim.v.searchforward == 1
    local going_forward = go_same_dir and forward or (not forward)

    -- Is there a match WITHOUT wrapping?
    local flags = "nW" .. (going_forward and "" or "b") -- "W" = no wrap
    local pos = vim.fn.searchpos(pat, flags)
    local will_wrap = (pos[1] == 0)

    return will_wrap and "wrap" or "ok", going_forward
end

local function repeat_search(go_same_dir)
    local status, forward = will_wrap_search(go_same_dir)

    if status == "no_pattern" then
        show_wrap_popup("⛔ no previous / pattern", "WrapError")
        return
    elseif status == "no_match" then
        local pat = vim.fn.getreg("/")
        -- escape any newlines to avoid multi-line chaos
        pat = pat:gsub("\n", "\\n")
        local msg = "⛔ pattern not found\n" .. pat
        show_wrap_popup(msg, "WrapError")
        vim.cmd("nohlsearch")
        return
    elseif status == "wrap" and vim.o.wrapscan then
        show_wrap_popup(forward and "⟲ wrapping to TOP" or "⟲ wrapping to BOTTOM",
            forward and "WrapForward" or "WrapBackward")
    end

    -- Run the real repeat; pcall just in case something still errors
    local ok = pcall(function()
        vim.cmd.normal({ go_same_dir and "n" or "N", bang = true })
    end)
    if not ok then
        show_wrap_popup("⛔ search failed", "WrapError")
    end
end

-- ── NEW: diagnostics wrap detector for ]d / [d ────────────────────────────
local function diags_will_wrap(forward)
    local diags = vim.diagnostic.get(0) -- current buffer
    if #diags == 0 then return false end
    table.sort(diags, function(a, b)
        if a.lnum == b.lnum then return (a.col or 0) < (b.col or 0) end
        return a.lnum < b.lnum
    end)
    local cur = vim.api.nvim_win_get_cursor(0) -- {row1, col0}
    local row, col = cur[1] - 1, cur[2]

    if forward then
        for _, d in ipairs(diags) do
            local dc = d.col or 0
            if d.lnum > row or (d.lnum == row and dc > col) then
                return false -- there is a next diag without wrapping
            end
        end
        return true -- would wrap to top
    else
        for i = #diags, 1, -1 do
            local d = diags[i]
            local dc = d.col or 0
            if d.lnum < row or (d.lnum == row and dc < col) then
                return false -- there is a previous diag without wrapping
            end
        end
        return true -- would wrap to bottom
    end
end

local function goto_diag_with_popup(forward)
    local diags = vim.diagnostic.get(0)
    if #diags == 0 then
        show_wrap_popup("⛔ no diagnostics", "WrapError")
        return
    end

    if diags_will_wrap(forward) then
        show_wrap_popup(forward and "⟲ diagnostics: wrapping to TOP"
            or "⟲ diagnostics: wrapping to BOTTOM",
            forward and "DiagWrapForward" or "DiagWrapBackward")
    end

    local ok = pcall(function()
        if forward then
            vim.diagnostic.goto_next({ wrap = true })
        else
            vim.diagnostic.goto_prev({ wrap = true })
        end
    end)
    if not ok then
        show_wrap_popup("⛔ diagnostic jump failed", "WrapError")
    end
end

-- Keymaps
vim.keymap.set("n", "n", function() repeat_search(true) end, { silent = true, desc = "Next match (wrap-aware)" })
vim.keymap.set("n", "N", function() repeat_search(false) end, { silent = true, desc = "Prev match (wrap-aware)" })

vim.keymap.set("n", "]d", function() goto_diag_with_popup(true) end,
    { silent = true, desc = "Next diagnostic (wrap-aware)" })
vim.keymap.set("n", "<leader>n", function() goto_diag_with_popup(true) end,
    { silent = true, desc = "Next diagnostic (wrap-aware)" })

vim.keymap.set("n", "[d", function() goto_diag_with_popup(false) end,
    { silent = true, desc = "Prev diagnostic (wrap-aware)" })
vim.keymap.set("n", "<leader>N", function() goto_diag_with_popup(false) end,
    { silent = true, desc = "Prev diagnostic (wrap-aware)" })
