return {

  -- === Tpope Essentials ===
  { "tpope/vim-sensible" },
  {
    "tpope/vim-surround",
    keys = { "ys", "cs", "ds", { "S", mode = "v" } },
  },
  { "tpope/vim-repeat", event = "VeryLazy" },
  { "tpope/vim-commentary", keys = { "gc", { "gc", mode = "v" } } },
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse" },
    keys = {
      { "<leader>gs", "<cmd>Git<cr>", desc = "Git status" },
      { "<leader>gc", "<cmd>Git commit<cr>", desc = "Git commit" },
      { "<leader>gp", "<cmd>Git push<cr>", desc = "Git push" },
      { "<leader>gl", "<cmd>Git pull<cr>", desc = "Git pull" },
    },
  },
  { "tpope/vim-rhubarb", dependencies = "tpope/vim-fugitive" },
  { "tpope/vim-eunuch", cmd = { "Remove", "Delete", "Move", "Chmod", "Mkdir", "SudoWrite" } },
  { "tpope/vim-unimpaired", event = "VeryLazy" },
  { "tpope/vim-abolish", cmd = { "Abolish", "Subvert" } },
  { "tpope/vim-dispatch", cmd = { "Dispatch", "Make", "Focus", "Start" } },
  { "tpope/vim-endwise", event = "InsertEnter" },
  { "tpope/vim-speeddating", keys = { "<C-a>", "<C-x>" } },
  { "tpope/vim-sleuth" }, -- Auto-detect indentation
}
