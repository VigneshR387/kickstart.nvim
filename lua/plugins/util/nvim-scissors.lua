return {
  'chrisgrieser/nvim-scissors',
  dependencies = 'folke/snacks.nvim', -- either snacks, fzf-lua, telescope
  -- dependencies = "ibhagwan/fzf-lua",
  -- dependencies = "nvim-telescope/telescope.nvim",
  opts = {
    snippetDir = '~/.config/nvim/snippets',
    editSnippetPopup = {
      height = 0.4, -- relative to the window, between 0-1
      width = 0.6,
      border = vim.o.winborder,
      keymaps = {
        -- if not mentioned otherwise, the keymaps apply to normal mode
        cancel = 'q',
        saveChanges = '<CR>', -- alternatively, can also use `:w`
        goBackToSearch = '<BS>',
        deleteSnippet = '<C-BS>',
        duplicateSnippet = '<C-d>',
        openInFile = '<C-o>',
        insertNextPlaceholder = '<C-p>', -- insert & normal mode
        showHelp = '?',
      },
    },

    snippetSelection = {
      picker = 'auto', ---@type "auto"|"telescope"|"snacks"|"vim.ui.select"

      fzfLua = {
        -- same format as fzf_opts in `:h fzf-lua-customization`
        fzf_opts = {},

        -- suppress warnings from fzf-lua.
        -- This is true by default, since commonly-used fzf-lua presets
        -- create warnings due to border settings.
        silent = true,

        -- same format as winopts in `:h fzf-lua-customization`
        winopts = {
          preview = {
            hidden = false,
          },
        },
      },

      telescope = {
        -- By default, the query only searches snippet prefixes. Set this to
        -- `true` to also search the body of the snippets.
        alsoSearchSnippetBody = false,

        -- accepts the common telescope picker config
        opts = {
          layout_strategy = 'horizontal',
          layout_config = {
            horizontal = { width = 0.9 },
            preview_width = 0.6,
          },
        },
      },

      -- `snacks` picker configurable via snacks config,
      -- see https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
    },

    -- `none` writes as a minified json file using `vim.encode.json`.
    -- `yq`/`jq` ensure formatted & sorted json files, which is relevant when
    -- you version control your snippets. To use a custom formatter, set to a
    -- list of strings, which will then be passed to `vim.system()`.
    -- TIP: `jq` is already pre-installed on newer versions of macOS.
    ---@type "yq"|"jq"|"none"|string[]
    jsonFormatter = 'jq',

    backdrop = {
      enabled = true,
      blend = 50, -- between 0-100
    },
    icons = {
      scissors = '󰩫',
    },
  },

  keys = {
    {
      '<leader>ae',
      function() require('scissors').editSnippet() end,
      mode = 'n',
      desc = 'Snippet: Edit',
    },

    -- when used in visual mode, prefills the selection as snippet body
    {
      '<leader>aa',
      function() require('scissors').addNewSnippet() end,
      mode = { 'n', 'x' },
      desc = 'Snippet: Add',
    },
  },
}
