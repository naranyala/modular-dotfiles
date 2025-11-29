-- SINGLE FILE NEOVIM CONFIG

-- require("setup_jsvue_mode") -- BEST
-- require("setup_casm_mode") -- BEST
require("setup_crust_mode") -- BEST

require("atomic.ok_features")
require("atomic.ok_vue_snippets")
require("atomic.ok_c99_snippets")

-- require("lib_grepnav").setup()
-- require("lib.simplenav")
-- require("lib.simplenav").setup()
-- require("lib.theme_paperlike_day").setup()
-- require("lib.theme_paperlike_night").setup()

require("lib.bookmark").setup()
require("lib.disable_tabline")
require("lib.ag_filepicker")
require("lib.todo_search").setup()

require("lib.grepnav").setup({
    engine_priority = { "rg" }, -- never fall back to plain grep
    root_markers = { ".git", "pyproject.toml", ".root" },
    ignore = { ".git", "node_modules", "venv", "build", "*.min.js" },
    rg_args = "--vimgrep --no-heading --smart-case --type-add 'ts:*.tsx' --type-add 'vue:*.vue'",
    window_height_ratio = 0.5,
    mappings = true,
})


-- prevent command bar grow
vim.keymap.set("n", "<C-Up>", "<Nop>")
vim.keymap.set("n", "<C-Down>", "<Nop>")
vim.keymap.set("n", "<C-Left>", "<Nop>")
vim.keymap.set("n", "<C-Right>", "<Nop>")
