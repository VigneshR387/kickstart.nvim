local root = require 'util.root'
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
    {
      '<leader>fe',
      desc = 'Explorer Snacks (cwd)',
      function()
        local explorer = Snacks.picker.get({ source = 'explorer' })[1]

        if explorer then
          explorer:focus()
        else
          Snacks.explorer()
        end
      end,
    },
    {
      '<leader>fE',
      desc = 'Explorer Snacks (root)',
      function()
        local explorer = Snacks.picker.get({ source = 'explorer' })[1]

        if explorer then
          explorer:focus()
        else
          Snacks.explorer { cwd = root() }
        end
      end,
    },
    { '<leader>e', '<leader>fe', desc = 'Explorer Snacks (root dir)', remap = true },
    { '<leader>E', '<leader>fE', desc = 'Explorer Snacks (cwd)', remap = true },
  },
}
