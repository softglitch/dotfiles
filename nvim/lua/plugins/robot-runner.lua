return {
    "totu/robot-runner.nvim",
    config = function()
        require("robot_runner").setup({
            filetypes = { "robot" },
            test_command = "./testrunner --no-pull -w -t {test} {file}",
            suite_command = "./testrunner -w {file}",
            tag_command = "./testrunner -w --include {tag} {file}",
            window = { width = 0.56, height = 0.5, border = "rounded" },
            clear_on_run = false,
            --display_mode = "sign_column",
        })
    end,
}
