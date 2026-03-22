return {
  'MagicDuck/grug-far.nvim',
  enabled = true,
  lazy = true,
  opts = { headerMaxWidth = 80 },
  cmd = { 'GrugFar', 'GrugFarWithin' },
  keys = {
    {
      '<leader>sr',
      function()
        local grug = require 'grug-far'
        local ext = vim.bo.buftype == '' and vim.fn.expand '%:e'
        grug.open {
          transient = true,
          prefills = {
            filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
          },
        }
      end,
      mode = { 'n', 'x' },
      desc = 'Search and Replace',
    },
    {
      '<leader>s1',
      '<cmd>lua require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })<cr>',
      mode = { 'v', 'n' },
      desc = 'Search and Replace for the current file',
    },

    {
      '<leader>sv',
      function() require('grug-far').open { visualSelectionUsage = 'operate-within-range' } end,
      mode = { 'n', 'x' },
      desc = 'grug-far: Search within range',
    },
  },
}
