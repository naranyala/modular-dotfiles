return {

    { "rebelot/kanagawa.nvim", priority = 1000,
        config = function() vim.cmd.colorscheme("kanagawa") end },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            -- "nvim-tree/nvim-web-devicons"
        },
        config = function()
            local function file_stats()
                local buf = vim.api.nvim_get_current_buf()
                if vim.api.nvim_buf_get_option(buf, "buftype") ~= "" then
                    return "" -- Skip for non-file buffers
                end

                -- Line count
                local lines = vim.api.nvim_buf_line_count(buf)

                -- Word count
                local words = 0
                local content = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                for _, line in ipairs(content) do
                    for _ in line:gmatch("%S+") do
                        words = words + 1
                    end
                end

                -- Character count
                local chars = #table.concat(content, "")

                return string.format("lines %d | words %d | chars %d", lines, words, chars)
            end

            require("lualine").setup({
                options = {
                    theme = "auto",
                    component_separators = "",
                    section_separators = "",
                    disabled_filetypes = {},
                    globalstatus = true,
                },
                sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = {
                        {
                            "filename",
                            path = 2, -- 2 = absolute path
                            symbols = {
                                modified = "[+]",
                                readonly = "[-]",
                                unnamed = "[No Name]",
                            },
                        },
                    },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {
                        { file_stats },
                    },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = {
                        {
                            "filename",
                            path = 2, -- Absolute path for inactive buffers too
                        },
                    },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = {},
            })
        end,
    },

}
