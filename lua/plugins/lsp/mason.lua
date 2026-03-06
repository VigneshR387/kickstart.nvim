return {
  'mason-org/mason.nvim',
  dependencies = {
    'mason-org/mason-lspconfig.nvim',
    {
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      opts = {
        ensure_installed = {
          'lua_ls',
          'stylua',
          'eslint_d',
          'biome',
          'pylint',
          'markdownlint',
        },
      },
    },
  },
  opts = {}, -- calls require('mason').setup({})
}
