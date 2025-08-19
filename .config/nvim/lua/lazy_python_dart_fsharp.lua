-- init.lua - Compact Neovim config for Python, Dart/Flutter, F#

-----------------------------------------------------------
-- 1. BOOTSTRAP LAZY.NVIM
-----------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-----------------------------------------------------------
-- 2. SETTINGS & KEYMAPS
-----------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Essential options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 8
vim.opt.updatetime = 250
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true

local keymap = vim.keymap.set

-- Basic keymaps
keymap("i", "jk", "<ESC>")
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>")
keymap("n", "<C-h>", "<C-w><C-h>")
keymap("n", "<C-l>", "<C-w><C-l>")
keymap("n", "<C-j>", "<C-w><C-j>")
keymap("n", "<C-k>", "<C-w><C-k>")
keymap("n", "<S-h>", "<cmd>bprevious<CR>")
keymap("n", "<S-l>", "<cmd>bnext<CR>")
keymap("n", "<leader>bd", "<cmd>bdelete<CR>")
keymap("v", "J", ":m '>+1<CR>gv=gv")
keymap("v", "K", ":m '<-2<CR>gv=gv")
keymap("v", "<", "<gv")
keymap("v", ">", ">gv")
keymap("n", "<C-s>", "<cmd>w<CR>")

-----------------------------------------------------------
-- 3. PLUGINS
-----------------------------------------------------------
require("lazy").setup({

	-- Core
	{ "nvim-lua/plenary.nvim" },

	-- Colorscheme
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("catppuccin-mocha")
		end,
	},

	-- File navigation with oil.nvim
	{
		"stevearc/oil.nvim",
		config = function()
			require("oil").setup({
				default_file_explorer = true,
				columns = { "icon", "permissions", "size" },
				buf_options = { buflisted = false, bufhidden = "hide" },
				win_options = { wrap = false, signcolumn = "no", cursorcolumn = false },
				delete_to_trash = true,
				skip_confirm_for_simple_edits = true,
				view_options = { show_hidden = false },
				keymaps = {
					["g?"] = "actions.show_help",
					["<CR>"] = "actions.select",
					["<C-v>"] = "actions.select_vsplit",
					["<C-h>"] = "actions.select_split",
					["-"] = "actions.parent",
					["_"] = "actions.open_cwd",
					["`"] = "actions.cd",
					["~"] = "actions.tcd",
					["gs"] = "actions.change_sort",
					["gx"] = "actions.open_external",
					["g."] = "actions.toggle_hidden",
				},
			})
			keymap("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Open oil" })
		end,
	},

	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.5",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		config = function()
			local telescope = require("telescope")
			local builtin = require("telescope.builtin")

			telescope.setup({
				defaults = {
					mappings = {
						i = {
							["<C-k>"] = require("telescope.actions").move_selection_previous,
							["<C-j>"] = require("telescope.actions").move_selection_next,
						},
					},
				},
			})

			telescope.load_extension("fzf")

			keymap("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
			keymap("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
			keymap("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
			keymap("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
			keymap("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
		end,
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"lua",
					"vim",
					"python",
					"dart",
					"fsharp",
					"javascript",
					"typescript",
					"html",
					"css",
					"json",
				},
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},

	-- Git
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			local gs = require("gitsigns")
			gs.setup()
			keymap("n", "<leader>gp", gs.preview_hunk, { desc = "Preview hunk" })
			keymap("n", "<leader>gb", function()
				gs.blame_line({ full = true })
			end, { desc = "Blame line" })
			keymap("n", "[h", gs.prev_hunk, { desc = "Previous hunk" })
			keymap("n", "]h", gs.next_hunk, { desc = "Next hunk" })
		end,
	},

	-- LSP
	{ "neovim/nvim-lspconfig" },
	{ "williamboman/mason.nvim", config = true },
	{ "williamboman/mason-lspconfig.nvim" },

	-- Completion
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				},
			})
		end,
	},

	-- Flutter/Dart
	{
		"akinsho/flutter-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "stevearc/dressing.nvim" },
		ft = "dart",
		config = function()
			require("flutter-tools").setup({
				ui = { border = "rounded" },
				decorations = { statusline = { device = true } },
				flutter_lookup_cmd = nil,
				widget_guides = { enabled = false },
				closing_tags = { enabled = true },
				lsp = {
					settings = {
						showTodos = true,
						completeFunctionCalls = true,
					},
				},
			})
		end,
	},

	-- F# Support
	{ "ionide/ionide-vim", ft = "fsharp" },

	-- UI
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = { theme = "catppuccin" },
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { "filename" },
					lualine_x = { "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
		end,
	},

	-- Essential utilities
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			local autopairs = require("nvim-autopairs")
			autopairs.setup({})

			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},

	{ "numToStr/Comment.nvim", config = true },

	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		config = true,
	},

	-- Formatting
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					python = { "isort", "black" },
					dart = { "dart_format" },
					fsharp = { "fantomas" },
					lua = { "stylua" },
					javascript = { "prettier" },
					typescript = { "prettier" },
				},
				format_on_save = { timeout_ms = 500, lsp_fallback = true },
			})

			keymap("n", "<leader>cf", function()
				require("conform").format({ async = true, lsp_fallback = true })
			end, { desc = "Format code" })
		end,
	},
})

-----------------------------------------------------------
-- 4. LSP SETUP
-----------------------------------------------------------
local lspconfig = require("lspconfig")
local mason_lspconfig = require("mason-lspconfig")

mason_lspconfig.setup({
	ensure_installed = { "pyright", "dartls", "fsautocomplete", "lua_ls" },
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local on_attach = function(client, bufnr)
	local opts = { buffer = bufnr, silent = true }
	keymap("n", "gd", vim.lsp.buf.definition, opts)
	keymap("n", "gr", vim.lsp.buf.references, opts)
	keymap("n", "gi", vim.lsp.buf.implementation, opts)
	keymap("n", "K", vim.lsp.buf.hover, opts)
	keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
	keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	keymap("n", "[d", vim.diagnostic.goto_prev, opts)
	keymap("n", "]d", vim.diagnostic.goto_next, opts)
end

mason_lspconfig.setup_handlers({
	function(server_name)
		lspconfig[server_name].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})
	end,

	["lua_ls"] = function()
		lspconfig.lua_ls.setup({
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				Lua = {
					runtime = { version = "LuaJIT" },
					workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
					completion = { callSnippet = "Replace" },
					diagnostics = { globals = { "vim" } },
				},
			},
		})
	end,
})

-----------------------------------------------------------
-- 5. AUTOCOMMANDS & DIAGNOSTICS
-----------------------------------------------------------
-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Remove trailing whitespace
vim.api.nvim_create_autocmd("BufWritePre", {
	command = "%s/\\s\\+$//e",
})

-- Diagnostics
vim.diagnostic.config({
	virtual_text = { spacing = 2, prefix = "●" },
	float = { border = "rounded" },
	signs = true,
	underline = true,
	severity_sort = true,
})

local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

print("Neovim configuration loaded! 🚀")
