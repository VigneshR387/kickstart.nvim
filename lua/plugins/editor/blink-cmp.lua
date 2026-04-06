return { -- Autocompletion
  'saghen/blink.cmp',
  enabled = true,
  event = { 'InsertEnter', 'CmdlineEnter' },
  version = '1.*',
  dependencies = {
    'L3MON4D3/LuaSnip',
    'Kaiser-Yang/blink-cmp-git',
    'moyiz/blink-emoji.nvim',
  },
  --- @module 'blink.cmp'
  --- @type blink.cmp.Config
  opts = {
    keymap = {
      -- 'default' (recommended) for mappings similar to built-in completions
      --   <c-y> to accept ([y]es) the completion.
      --    This will auto-import if your LSP supports it.
      --    This will expand snippets if the LSP sent a snippet.
      -- 'super-tab' for tab to accept
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- For an understanding of why the 'default' preset is recommended,
      -- you will need to read `:help ins-completion`
      --
      -- No, but seriously. Please read `:help ins-completion`, it is really good!
      --
      -- All presets have the following mappings:
      -- <tab>/<s-tab>: move to right/left of your snippet expansion
      -- <c-space>: Open menu or open docs if already open
      -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
      -- <c-e>: Hide menu
      -- <c-k>: Toggle signature help
      --
      -- See :h blink-cmp-config-keymap for defining your own keymap
      preset = 'default',
      -- ['<S-Tab>'] = { 'select_prev', 'fallback' },
      -- ['<Tab>'] = { 'select_next', 'fallback' },
      --
      -- ['<Up>'] = false,
      -- ['<Down>'] = false,
      -- -- disable a keymap from the preset
      -- ['<C-e>'] = false, -- or {}
      --
      -- -- show with a list of providers
      -- ['<C-space>'] = { function(cmp) cmp.show { providers = { 'snippets' } } end },
      --
      -- -- control whether the next command will be run when using a function
      -- ['<C-n>'] = {
      --   function(cmp)
      --     if some_condition then return end -- runs the next command
      --     if some_other_condition then return 'a' end -- simulate keypresses, doesn't run the next command
      --     return true -- doesn't run the next command
      --   end,
      --   'select_next',
      -- },
      --
      -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
      --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
      --
      --Keymap v2
      ['<c-x>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<c-e>'] = { 'cancel', 'fallback' },
      ['<tab>'] = {
        'accept',
        'snippet_forward',
        'fallback',
      },
      ['<c-y>'] = { 'select_and_accept', 'fallback' },
      ['<c-k>'] = { 'select_prev', 'fallback' },
      ['<up>'] = { 'select_prev', 'fallback' },
      ['<c-j>'] = { 'select_next', 'fallback' },
      ['<down>'] = { 'select_next', 'fallback' },
    },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono',
    },

    completion = {
      -- By default, you may press `<c-space>` to show the documentation.
      -- Optionally, set `auto_show = true` to show the documentation after a delay.
      documentation = { auto_show = false, auto_show_delay_ms = 500 },
    },

    sources = {
      -- add lazydev to your completion providers
      default = { 'emoji', 'git', 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          -- make lazydev completions top priority (see `:h blink.cmp`)
          score_offset = 100,
        },
        snippets = {
          name = 'snippets',
          enabled = true,
          max_items = 15,
          min_keyword_length = 2,
          module = 'blink.cmp.sources.snippets',
          score_offset = 85, -- the higher the number, the higher the priority
        },
        git = {
          module = 'blink-cmp-git',
          name = 'Git',
        },
        emoji = {
          module = 'blink-emoji',
          name = 'Emoji',
          score_offset = 15, -- Tune by preference
          opts = {
            insert = true, -- Insert emoji (default) or complete its name
            ---@type string|table|fun():table
            trigger = function() return { ';' } end,
          },
          should_show_items = function()
            return vim.tbl_contains(
              -- Enable emoji completion only for git commits and markdown.
              -- By default, enabled for all file-types.
              { 'gitcommit', 'markdown' },
              vim.o.filetype
            )
          end,
        },
      },
    },

    snippets = { preset = 'luasnip' },

    -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
    -- which automatically downloads a prebuilt binary when enabled.
    --
    -- By default, we use the Lua implementation instead, but you may enable
    -- the rust implementation via `'prefer_rust_with_warning'`
    --
    -- See :h blink-cmp-config-fuzzy for more information
    fuzzy = { implementation = 'lua' },

    -- Shows a signature help window while you type arguments for a function
    signature = { enabled = true },
  },
}
