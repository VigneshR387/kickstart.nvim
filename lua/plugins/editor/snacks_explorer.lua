return {
  'folke/snacks.nvim',
  priority = 1000,
  opts = {
    explorer = {
      enabled = true,
      replace_netrw = true, -- Replace netrw with the snacks explorer
      trash = true, -- Use the system trash when deleting files
    },
  },
  keys = {
    { '<leader>fe', desc = 'Explorer Snacks (cwd)', function() Snacks.explorer() end },
    { '<leader>fE', desc = 'Explorer Snacks (root)', function() Snacks.explorer { cwd = '~' } end },
  },
}
