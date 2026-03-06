return {
  'folke/snacks.nvim',
  keys = {
    { '<leader>.', function() Snacks.scratch() end, desc = 'Toggle Scratch Buffer' },
    { '<leader>S', function() Snacks.scratch.select() end, desc = 'Select Scratch Buffer' },
    { '<leader>dps', function() Snacks.profiler.scratch() end, desc = 'Profiler Scratch Buffer' },
  },
}
