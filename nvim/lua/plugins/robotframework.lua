--return {}
-- vim.filetype.add({
--   extension = {
--     robot = "robot",
--     resource = "robot",
--   }
-- })

-- Robot Framework highlighting via Tree-sitter
-- return {
--   "nvim-treesitter/nvim-treesitter",
--   build = ":TSUpdate",
--   config = function()
--     local configs = require("nvim-treesitter.configs")
--     local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

--     -- Register the Robot Framework parser
--     parser_config.robot = {
--       install_info = {
--         url = "https://github.com/Hubro/tree-sitter-robot",
--         files = { "src/parser.c" },  -- Neovim compiles this directly, no npm
--         branch = "master",
--       },
--       filetype = "robot",
--     }

--     configs.setup({
--       highlight = { enable = true },
--       ensure_installed = { "robot" },
--     })

--     -- Make sure .robot/.resource files use 'robot' filetype
--     vim.filetype.add({
--       extension = {
--         robot = "robot",
--         resource = "robot",
--       },
--     })
--   end,
-- }


return {
    {
        "totu/robotframework-vim",
        name = "robotframework-vim",
    }
}
