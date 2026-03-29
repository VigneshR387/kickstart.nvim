return {
  'L3MON4D3/LuaSnip',
  version = '2.*',
  lazy = true,
  build = (function()
    if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then return end
    return 'make install_jsregexp'
  end)(),
  dependencies = {
    {
      'rafamadriz/friendly-snippets',
      config = function() require('luasnip.loaders.from_vscode').lazy_load() end,
    },
  },

  opts = function()
    require('luasnip.loaders.from_lua').lazy_load {
      paths = {
        '~/.config/nvim/snippets',
      },
    }

    require('luasnip.loaders.from_vscode').lazy_load {
      paths = {
        '~/.config/nvim/snippets',
      },
    }
  end,
  keys = {
    {
      '<C-K>',
      function() require('luasnip').expand() end,
      mode = 'i',
      silent = true,
    },
    {
      '<C-L>',
      function() require('luasnip').jump(1) end,
      mode = { 'i', 's' },
      silent = true,
    },
    {
      '<C-J>',
      function() require('luasnip').jump(-1) end,
      mode = { 'i', 's' },
      silent = true,
    },
    {
      '<C-E>',
      function()
        local ls = require 'luasnip'
        if ls.choice_active() then ls.change_choice(1) end
      end,
      mode = { 'i', 's' },
      silent = true,
    },
  },
}
