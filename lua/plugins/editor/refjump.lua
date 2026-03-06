return {
  'mawkler/refjump.nvim',
  enabled = false,
  event = 'LspAttach', -- Uncomment to lazy load
  opts = {
    keymaps = {
      next = ']]',
      prev = '[[',
    },
  },
}
