-- SINGLE FILE NEOVIM CONFIG

-- require("lazy_suckless_001") -- OK
-- require("lazy_suckless_002") -- MEH
-- require("lazy_suckless_003") -- OK
-- require("lazy_suckless_004") -- MEH
-- require("lazy_suckless_005") -- BEST but bug copy/paste
-- require("lazy_suckless_006") -- MEH
require("lazy_suckless_007") -- BEST
-- require("lazy_suckless_008") -- MEH
-- require("lazy_suckless_009") -- ERROR
-- require("lazy_suckless_010") -- ERROR

-- require("best_legacy/lazy_tpope_stack")
-- require("best_legacy/lazy_c_asm_toolchain")
-- require("best_legacy/lazy_tailored_cprogramming")
-- require("best_legacy/lazy_goto_definition") -- BEST
-- require("best_legacy/lazy_rustcode_focused")
-- require("best_legacy/lazy_sophisticated")
-- require("best_legacy/lazy_alternative")
-- require("best_legacy/lazy_minimalism")

require("on_demand_fn.ok_features")
require("on_demand_fn.ok_vue_snippets")
require("on_demand_fn.ok_c99_snippets")


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

