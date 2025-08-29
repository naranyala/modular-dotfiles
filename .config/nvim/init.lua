-- SINGLE FILE NEOVIM CONFIG

-- WAJIB: lazy.nvim, mason, treesitter, harpoon, oil, fzf, rg

-- require("lazy_pycpp_v1")
-- require("lazy_pycpp_v2")
-- require("lazy_pycpp_v3")
-- require("lazy_pycpp_v4")
--
-- require("lazy_jsx_frontend") -- BEST
-- require("lazy_ocaml_first") -- BEST
-- require("lazy_scala_jvm") -- BEST
-- require("lazy_python_dart_fsharp") -- BEST
require("lazy_goto_definition") -- BEST

-- require("lazy_ergonomic_new")
-- require("lazy_vimscript")
-- require("lazy_ergonomic1")
-- require("lazy_ergonomic2")
-- require("lazy_readthedocs")
-- require("lazy_massive") -- BEST
-- require("lazy_standout") -- BEST
-- require("lazy_unique") -- BEST
--
-- require("lazy_gitfirst")
-- require("lazy_normal") -- BEST
-- require("lazy_normal_improved") -- BEST
-- require("lazy_research") -- BUG
-- require("lazy_llm_assistant") -- BUG
--
-- require("lazy_legacy") -- OK
-- require("lazy_primary") -- OK
-- require("lazy_with_lsp") -- OK
-- require("lazy_movement") -- OK
-- require("lazy_adventure") -- OK
-- require("lazy_lightweight") -- OK

-- require("lazy_enhanced") -- MEH
-- require("lazy_improved") -- MEH
-- require("lazy_ok") -- MEH
-- require("lazy_secondary") -- MEH
-- require("lazy_innovative") -- MEH
-- require("lazy_experiment") -- MEH

-- require("lazy_special") -- BUG
-- require("lazy_purist") -- BUG
-- require("lazy_modular") -- BUG
-- require("lazy_powerful") -- BUG
-- require("lazy_lowlevel") -- BUG
-- require("lazy_alternative") -- BUG
-- require("lazy_future") -- BUG

-- Prevent horizontal scrolling
vim.o.sidescroll = 0
vim.o.sidescrolloff = 0

vim.opt.clipboard = "unnamedplus" -- clipboard support
vim.o.wrap = true                 -- Enable line wrapping
vim.o.textwidth = 80              -- Optional: Set max text width for formatting
vim.o.colorcolumn = "+1"          -- Optional: Add a vertical guideline

-- require("theme_paperlike").setup()
-- require("theme_paperlike_dark").setup()

-- vim.cmd("colorscheme paperlike")

vim.o.termguicolors = true

-- require("lib_theme_paperlike_day").setup()
require("lib_theme_paperlike_night").setup()
-- require("lib_keybindings")
