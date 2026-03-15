return {
  'stevearc/aerial.nvim',
  event = 'LazyFile',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  opts = function()
    Snacks.keymap.set({ 'n', 'v' }, '<leader>mo', '<cmd>AerialToggle!<CR>', { ft = 'markdown', desc = 'Toggle Outline(Ariel)' })
    -- NOTE: The options should be returned inside opts =  function()
    return { attach_mode = 'window' }
  end,
}
