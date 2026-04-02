-- LSP Plugins

return {
  -- Main LSP Configuration
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs and related tools to stdpath for Neovim
    -- Mason must be loaded before its dependents so we need to set it up here.
    -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
    'mason-org/mason.nvim',

    -- This plugin streamlines Neovim's LSP setup by automating server installation and activation, providing helpful management commands, and mapping mason.nvim packages to nvim-lspconfig configurations.
    'mason-org/mason-lspconfig.nvim',
  },
  event = { 'BufReadPost', 'BufNewFile' },
  config = vim.schedule_wrap(function()
    -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
    -- and elegantly composed help section, `:help lsp-vs-treesitter`

    local snacks_words_group = vim.api.nvim_create_augroup('snacks-words', { clear = true })
    -- disable Snacks.words when lsp detachs

    vim.api.nvim_create_autocmd('LspDetach', {
      group = snacks_words_group,
      callback = function(event) Snacks.words.disable(event.buf) end,
    })

    -- Enable the following language servers
    --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
    --  See `:help lsp-config` for information about keys and how to configure
    ---@type table<string, vim.lsp.Config>
    local servers = {
      -- clangd = {},
      -- gopls = {},
      -- pyright = {},
      -- rust_analyzer = {},
      --
      -- Some languages (like typescript) have entire language plugins that can be useful:
      --    https://github.com/pmizio/typescript-tools.nvim
      --
      -- But for many setups, the LSP (`ts_ls`) will work just fine
      -- ts_ls = {},
      jsonls = {
        -- lazy-load schemastore when needed
        before_init = function(_, new_config)
          new_config.settings.json.schemas = new_config.settings.json.schemas or {}
          vim.list_extend(new_config.settings.json.schemas, require('schemastore').json.schemas())
        end,
        settings = {
          json = {
            format = {
              enable = true,
            },
            validate = { enable = true },
          },
        },
      },
      yamlls = {
        before_init = function(_, new_config)
          new_config.settings.yaml.schemas = vim.tbl_deep_extend('force', new_config.settings.yaml.schemas or {}, require('schemastore').yaml.schemas())
        end,
        settings = {
          yaml = {
            schemaStore = {
              enable = false,
              url = '',
            },
          },
        },
      },

      bashls = {},

      stylua = {}, -- Used to format Lua code

      -- Special Lua Config, as recommended by neovim help docs
      lua_ls = {
        settings = {
          Lua = {},
        },
      },
      basedpyright = {},

      markdown_oxide = {
        -- Ensure that dynamicRegistration is enabled
        -- This allows the LS to take into account actions like Create Unresolved File, etc
        capabilities = vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(), require('blink.cmp').get_lsp_capabilities(), {
          workspace = {
            didChangeWatchedFiles = {
              dynamicRegistration = true,
            },
          },
        }),
      },

      harper_ls = {
        enabled = true,
        filetypes = { 'markdown', 'typst' },
        settings = {
          ['harper-ls'] = {
            userDictPath = '~/.config/nvim/spell/en.utf-8.add',
            -- linters = {
            --   -- Disabling ToDoHyphen because of
            --   -- https://github.com/Automattic/harper/issues/1573#issuecomment-3777776431
            --   -- -- ToDoHyphen = false,
            --   -- SentenceCapitalization = true,
            --   -- SpellCheck = true,
            -- },
            isolateEnglish = true,
            markdown = {
              -- [ignores this part]()
              -- [[ also ignores my marksman links ]]
              IgnoreLinkTitle = true,
            },
          },
        },
      },
      vtsls = {},
      mpls = {
        cmd = {
          'mpls',
          '--no-auto',
          '--theme',
          'dark',
          '--enable-emoji',
          '--enable-footnotes',
          -- "--enable-wikilinks",
        },
        root_markers = { '.marksman.toml', '.git' },
        filetypes = { 'markdown' },
        on_attach = function(client, bufnr)
          vim.api.nvim_create_autocmd('BufEnter', {
            pattern = { '*.md' },
            group = vim.api.nvim_create_augroup('lspconfig.mpls.focus', { clear = true }),
            callback = function(ctx)
              ---@diagnostic disable-next-line:param-type-mismatch
              client:notify('mpls/editorDidChangeFocus', { uri = ctx.match })
            end,
            desc = 'mpls: notify buffer focus changed',
          })
          vim.api.nvim_buf_create_user_command(
            bufnr,
            'LspMplsOpenPreview',
            function()
              client:exec_cmd {
                title = 'Preview markdown with mpls',
                command = 'open-preview',
              }
            end,
            { desc = 'Preview markdown with mpls' }
          )
          -- Optional keybinding
          vim.keymap.set('n', '<leader>mp', '<cmd>LspMplsOpenPreview<cr>', {
            buffer = bufnr,
            desc = 'Markdown Preview',
          })
        end,
      },
      taplo = {
        schema = {
          associations = {
            ['.*sesh\\.toml$'] = 'https://github.com/joshmedeski/sesh/raw/main/sesh.schema.json',
          },
        },
      },
    }
    for name, server in pairs(servers) do
      vim.lsp.config(name, server)
      vim.lsp.enable(name)
    end
  end),
}
