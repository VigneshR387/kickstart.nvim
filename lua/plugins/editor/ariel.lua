return {
  'stevearc/aerial.nvim',
  lazy = true,
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  opts = {
    attach_mode = 'window',
  },
  opts = function() Snacks.keymap.set('<leader>mo', '<cmd>AerialToggle!<CR>', { ft = 'markdown', desc = 'Toggle Outline(Ariel)' }) end,
}
