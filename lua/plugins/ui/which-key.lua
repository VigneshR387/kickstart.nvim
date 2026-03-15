return { -- Useful plugin to show you pending keybinds.
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {
    preset = 'helix',
    -- delay between pressing a key and opening which-key (milliseconds)
    delay = 0,
    icons = {
      mappings = vim.g.have_nerd_font,
      rules = {
        { pattern = 'yazi', icon = '󰇥', color = 'orange' },
        { pattern = 'overseer', icon = '', color = 'orange' },
      },
    },

    -- Document existing key chains
    spec = {
      {
        mode = { 'n', 'x' },
        { '<leader><tab>', group = 'tabs' },
        { '<leader>c', group = 'code' },
        { '<leader>d', group = 'debug' },
        { '<leader>dp', group = 'profiler' },
        { '<leader>f', group = 'file/find' },
        { '<leader>g', group = 'git' },
        { '<leader>gh', group = 'hunks' },
        { '<leader>i', group = 'image', icon = { icon = '󰋩', color = 'green' } },
        { '<leader>m', group = 'markdown', icon = { cat = 'filetype', name = 'markdown' } },
        { '<leader>o', group = 'overseer' },
        { '<leader>q', group = 'quit/session' },
        { '<leader>s', group = 'search' },
        { '<leader>u', group = 'ui' },
        { '<leader>x', group = 'diagnostics/quickfix' },
        { '[', group = 'prev' },
        { ']', group = 'next' },
        { 'g', group = 'goto' },
        { 'gs', group = 'surround' },
        { 'z', group = 'fold' },
        {
          '<leader>b',
          group = 'buffer',
          expand = function() return require('which-key.extras').expand.buf() end,
        },
        {
          '<leader>w',
          group = 'windows',
          proxy = '<c-w>',
          expand = function() return require('which-key.extras').expand.win() end,
        },
        -- better descriptions
        { 'gx', desc = 'Open with system app' },

        -- Hide Harpoon keybindings

        { '<leader>1', hidden = true },
        { '<leader>2', hidden = true },
        { '<leader>3', hidden = true },
        { '<leader>4', hidden = true },
        { '<leader>5', hidden = true },
        { '<leader>6', hidden = true },
        { '<leader>7', hidden = true },
        { '<leader>8', hidden = true },
        { '<leader>9', hidden = true },
      },
    },
  },
  keys = {
    {
      '<leader>?',
      function() require('which-key').show { global = false } end,
      desc = 'Buffer Keymaps (which-key)',
    },
    {
      '<c-w><space>',
      function() require('which-key').show { keys = '<c-w>', loop = true } end,
      desc = 'Window Hydra Mode (which-key)',
    },
  },
}
