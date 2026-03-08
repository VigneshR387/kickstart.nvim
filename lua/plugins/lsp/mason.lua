return {
  'mason-org/mason.nvim',
  dependencies = {
    'mason-org/mason-lspconfig.nvim',
    {
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      opts = {
        ensure_installed = {
          -- Servers
          'lua_ls',
          'json-lsp',
          'yaml-language-server',
          -- linters
          'eslint_d',
          'biome',
          'pylint',
          -- Formatter
          'prettierd',
          'markdownlint-cli2',
          'shfmt',
          'stylua',
        },
      },
    },
  },
  opts = {}, -- calls require('mason').setup({})
  keys = { { '<leader>cm', '<cmd>Mason<cr>', desc = 'Mason' } },
}
