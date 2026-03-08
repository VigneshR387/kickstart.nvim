return {
  'mason-org/mason.nvim',
  dependencies = {
    'mason-org/mason-lspconfig.nvim',
    {
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      opts = {
        ensure_installed = {
          -- All
          'biome',
          -- Servers
          'lua_ls',
          'json-lsp',
          'yaml-language-server',
          'basedpyright',
          'bash-language-server',

          -- linters
          'eslint_d',
          'shellcheck',
          -- Formatter
          'prettierd',
          'markdown-toc',
          'shfmt',
          'stylua',
          'black',
          -- formatter+linter
          'ruff',
          'markdownlint-cli2',
        },
      },
    },
  },
  opts = {}, -- calls require('mason').setup({})
  keys = { { '<leader>cm', '<cmd>Mason<cr>', desc = 'Mason' } },
}
