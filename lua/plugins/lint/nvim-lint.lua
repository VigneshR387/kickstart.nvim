return {
  'mfussenegger/nvim-lint',
  event = 'LazyFile',
  opts = {
    events = { 'BufEnter', 'BufWritePost', 'InsertLeave' },
    linters_by_ft = {
      markdown = { 'markdownlint-cli2' },
      python = { 'ruff' },
      sh = { 'shellcheck' },
      bash = { 'shellcheck' },
    },
    linters = {
      ['markdownlint-cli2'] = {
        prepend_args = { '--config', os.getenv 'HOME' .. '/.config/nvim/.markdownlint.yaml', '-' },
      },
    },
  },
  config = function(_, opts)
    local lint = require 'lint'

    for name, linter in pairs(opts.linters) do
      if type(linter) == 'table' and type(lint.linters[name]) == 'table' then
        lint.linters[name] = vim.tbl_deep_extend('force', lint.linters[name], linter)
        if type(linter.prepend_args) == 'table' then
          lint.linters[name].args = lint.linters[name].args or {}
          vim.list_extend(lint.linters[name].args, linter.prepend_args)
        end
      else
        lint.linters[name] = linter
      end
    end

    lint.linters_by_ft = opts.linters_by_ft

    vim.api.nvim_create_autocmd(opts.events, {
      group = vim.api.nvim_create_augroup('nvim-lint', { clear = true }),
      callback = function() lint.try_lint() end,
    })

    vim.keymap.set('n', '<leader>L', function() lint.try_lint() end, { desc = 'Trigger linting for current file' })
  end,
}
