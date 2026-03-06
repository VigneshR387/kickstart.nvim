return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile', 'BufWritePost', 'InsertLeave' }, -- Events to trigger linting
  config = function()
    local lint = require 'lint'

    -- Define linters for specific file types (example for markdown and Python)
    lint.linters_by_ft = {
      markdown = { 'markdownlint-cli2' }, -- Requires markdownlint to be installed on your system
      python = { 'pylint' }, -- Requires pylint to be installed on your system
      -- Add more file types and linters as needed
    }

    -- Autocommand to run linting automatically on certain events
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = vim.api.nvim_create_augroup('lint_augroup', { clear = true }),
      callback = function() lint.try_lint() end,
    })

    -- Optional: set a keymap to manually trigger linting
    vim.keymap.set('n', '<leader>L', function() lint.try_lint() end, { desc = 'Trigger linting for current file' })
  end,
}
