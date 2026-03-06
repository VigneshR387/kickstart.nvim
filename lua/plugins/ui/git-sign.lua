-- Here is a more advanced example where we pass configuration
-- options to `gitsigns.nvim`.
--
-- See `:help gitsigns` to understand what the configuration keys do
return { -- Adds git related signs to the gutter, as well as utilities for managing changes
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },
  {
    'gitsigns.nvim',
    opts = function()
      Snacks.toggle({
        name = 'Git Signs',
        get = function() return require('gitsigns.config').config.signcolumn end,
        set = function(state) require('gitsigns').toggle_signs(state) end,
      }):map '<leader>uG'
    end,
  },
}
