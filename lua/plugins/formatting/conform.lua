return {
  'stevearc/conform.nvim',
  lazy = true,
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },

  keys = {
    {
      '<leader>cf',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      desc = '[F]ormat buffer',
    },
  },

  opts = {
    notify_on_error = false,

    formatters = {
      ['markdown-toc'] = {
        condition = function(_, ctx)
          for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
            if line:find '<!%-%- toc %-%->' then
              return true
            end
          end
        end,
      },

      ['markdownlint-cli2'] = {
        condition = function(_, ctx)
          local diag = vim.tbl_filter(function(d)
            return d.source == 'markdownlint'
          end, vim.diagnostic.get(ctx.buf))

          return #diag > 0
        end,
      },
    },

    formatters_by_ft = {
      lua = { 'stylua' },
      sh = { 'shfmt' },
      markdown = { 'prettierd', 'markdownlint-cli2', 'markdown-toc' },
      ['markdown.mdx'] = { 'prettierd', 'markdownlint-cli2', 'markdown-toc' },
    },
  },

  config = function(_, opts)
    require('conform').setup(opts)

    Util.format.register({
      name = 'conform.nvim',
      priority = 100,
      primary = true,

      format = function(buf)
        require('conform').format({ bufnr = buf })
      end,

      sources = function(buf)
        local ret = require('conform').list_formatters(buf) or {}
        return vim.tbl_map(function(v)
          return v.name
        end, ret)
      end,
    })
  end,
}
