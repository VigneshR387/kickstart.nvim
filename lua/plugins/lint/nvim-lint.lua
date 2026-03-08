return {
  'mfussenegger/nvim-lint',
  event = 'LazyFile',
  config = function()
    local lint = require 'lint'

    -- To get the filetype of a buffer you can run := vim.bo.filetype. The filetype can also be a compound filetype.
    -- For example, if you have a buffer with a filetype like yaml.ghaction,
    -- you can use either ghaction, yaml or the full yaml.ghaction as key in the linters_by_ft table and the linter will be picked up in that buffer.
    -- This is useful for linters like actionlint in combination with vim.filetype patterns like [".*/.github/workflows/.*%.yml"] = "yaml.ghaction",

    -- Define linters for specific file types (example for markdown and Python)
    lint.linters_by_ft = {
      markdown = { 'markdownlint-cli2' }, -- Requires markdownlint to be installed on your system
      python = { 'ruff' },
      sh = { 'shellcheck' },
      bash = { 'shellcheck' },
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
