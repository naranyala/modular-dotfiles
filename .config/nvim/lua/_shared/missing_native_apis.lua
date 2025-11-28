return {

    -- Oil.nvim (alternative to neo-tree/nvim-tree)
    {
        "stevearc/oil.nvim",
        dependencies = {
            -- "nvim-tree/nvim-web-devicons"

        },
        keys = {
            -- { "<leader><leader>", "<cmd>Oil<cr>", desc = "Open file explorer" },
            { "<leader>e", "<cmd>Oil<cr>", desc = "Open file explorer" },
            { "-",         "<cmd>Oil<cr>", desc = "Open parent directory" },
        },
        config = function()
            require("oil").setup({
                columns = { "icon" },
                view_options = { show_hidden = true },
                float = { padding = 10 },
                keymaps = {
                    ["<C-h>"] = false,
                    ["<C-l>"] = false,
                    ["<C-s>"] = "actions.select_split",
                    ["<C-v>"] = "actions.select_vsplit",
                },
            })
        end,
    },



    -- LSP
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            'hrsh7th/cmp-nvim-lsp',
            'j-hui/fidget.nvim',
        },
        config = function()
            require('fidget').setup {}
            require('mason').setup()
            require('mason-lspconfig').setup {
                ensure_installed = { 'clangd', 'cmake', 'lua_ls', 'ts_ls', 'vue_ls'}
            }

            local cap = require('cmp_nvim_lsp').default_capabilities()

vim.lsp.config('lua_ls', {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if
        path ~= vim.fn.stdpath('config')
        and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
      then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        -- Tell the language server which version of Lua you're using (most
        -- likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Tell the language server how to find Lua modules same way as Neovim
        -- (see `:h lua-module-load`)
        path = {
          'lua/?.lua',
          'lua/?/init.lua',
        },
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME
          -- Depending on the usage, you might want to add additional paths
          -- here.
          -- '${3rd}/luv/library'
          -- '${3rd}/busted/library'
        }
        -- Or pull in all of 'runtimepath'.
        -- NOTE: this is a lot slower and will cause issues when working on
        -- your own configuration.
        -- See https://github.com/neovim/nvim-lspconfig/issues/3189
        -- library = {
        --   vim.api.nvim_get_runtime_file('', true),
        -- }
      }
    })
  end,
  settings = {
    Lua = {}
  }
})


            -- Clangd with enhanced settings
            -- require('lspconfig').clangd.setup {

vim.lsp.config('clangd', {

                cmd = {
                    'clangd',
                    '--background-index',
                    '--clang-tidy',
                    '--header-insertion=iwyu',
                    '--completion-style=detailed',
                    '--function-arg-placeholders',
                    '--fallback-style=llvm',
                },
                init_options = {
                    usePlaceholders = true,
                    completeUnimported = true,
                    clangdFileStatus = true,
                },
 on_attach = function(client, bufnr)
    -- Example keymap to show hover info
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr, desc = "LSP Hover" })

    -- Example: Show diagnostics in a floating window
    vim.keymap.set('n', '<space>i', vim.diagnostic.open_float, { buffer = bufnr, desc = "Open Diagnostic Float" })
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { buffer = bufnr, desc = "Go to Previous Diagnostic" })
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { buffer = bufnr, desc = "Go to Next Diagnostic" })
  end,
            })

            -- Asm LSP (if available)
            -- require('lspconfig').asm_lsp.setup { capabilities = cap }
        end
    },

    -- completion
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline',
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
            'rafamadriz/friendly-snippets',
        },
        config = function()
            local cmp = require 'cmp'
            local luasnip = require 'luasnip'
            require('luasnip.loaders.from_vscode').lazy_load()

            cmp.setup {
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-n>'] = cmp.mapping.select_next_item(),
                    ['<C-p>'] = cmp.mapping.select_prev_item(),
                    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete {},
                    ['<CR>'] = cmp.mapping.confirm { select = true },
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                    ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.locally_jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                }),
                sources = cmp.config.sources {
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'buffer',  keyword_length = 3 },
                    { name = 'path' },
                },
                formatting = {
                    format = function(entry, item)
                        item.menu = ({
                            nvim_lsp = '[LSP]',
                            luasnip = '[Snip]',
                            buffer = '[Buf]',
                            path = '[Path]',
                        })[entry.source.name]
                        return item
                    end,
                },
            }

            -- cmdline completion
            cmp.setup.cmdline('/', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = { { name = 'buffer' } }
            })
            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = { { name = 'path' }, { name = 'cmdline' } }
            })
        end
    },

    -- which-key (shows keybindings)
    {
        'folke/which-key.nvim',
        event = 'VeryLazy',
        config = function()
            require('which-key').setup()
            require('which-key').add({
                { '<leader>f', group = 'Find' },
                { '<leader>h', group = 'Git Hunk' },
                { '<leader>c', group = 'Code' },
                { '<leader>r', group = 'Rename' },
            })
        end
    },

  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
      vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
    end
  },

}
