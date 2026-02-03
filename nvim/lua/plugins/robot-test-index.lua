return {
    "totu/robot-test-index.nvim",
    ft = "robot",
    config = function()
        -- try to load the module from lua/robot_test_index/init.lua
        local ok, robot = pcall(require, "robot_test_index")
        if not ok then
            -- don’t hard-crash Neovim if the plugin didn’t load for some reason
            vim.notify("robot_test_index not found: " .. tostring(robot), vim.log.levels.ERROR)
            return
        end

        vim.api.nvim_set_hl(0, "RobotTestNumber", { fg = "#888888", italic = false })
        robot.setup({
            position = "after",
            hl = "RobotTestNumber",
        })
    end,
}
