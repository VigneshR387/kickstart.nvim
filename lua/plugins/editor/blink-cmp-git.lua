return {
  -- Treesitter git parsers
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = {
        'git_config',
        'gitcommit',
        'git_rebase',
        'gitignore',
        'gitattributes',
      },
    },
  },

  {
    'saghen/blink.cmp',
    dependencies = {
      'Kaiser-Yang/blink-cmp-git',
    },
    opts = {
      snippets = {
        preset = 'luasnip',
      },
      sources = {
        default = { 'git', 'lsp', 'path', 'snippets', 'buffer' },

        providers = {
          git = {
            module = 'blink-cmp-git',
            name = 'Git',
          },
        },
      },
    },
  },
}
