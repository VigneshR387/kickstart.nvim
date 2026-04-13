return {
  'folke/snacks.nvim',
  keys = {
    { '<leader>.', function() Snacks.scratch() end, desc = 'Toggle Scratch Buffer' },
    { '<leader>S', function() Snacks.scratch.select() end, desc = 'Select Scratch Buffer' },
    { '<leader>dps', function() Snacks.profiler.scratch() end, desc = 'Profiler Scratch Buffer' },
    {
      '<leader>t.',
      function()
        -- Can implement your own logic for saving files by cwd, project, git branch, etc.
        local data = vim.fn.stdpath 'data'
        local root = Util.root.get() .. '/todo'
        vim.fn.mkdir(root, 'p')
        local file = root .. '/todo.md' -- IMPORTANT: must match checkmate `files` pattern

        ---@diagnostic disable-next-line: missing-fields
        Snacks.scratch.open {
          ft = 'markdown',
          file = file,
        }
      end,
      desc = 'Toggle Scratch Todo',
    },
  },
}
