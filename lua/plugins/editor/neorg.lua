return {
  'nvim-neorg/neorg',
  lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
  version = '*', -- Pin Neorg to the latest stable release
  config = true,
  dependencies = {
    'nvim-neorg/tree-sitter-norg',
    'nvim-neorg/tree-sitter-norg-meta',
  },
  opts = {
    load = {
      ['core.defaults'] = {},
      ['core.concealer'] = {},
      ['core.summary'] = {
        config = {
          strategy = 'by_path',
        },
      },
      ['core.journal'] = {
        config = {
          strategy = 'flat',
        },
      },
      ['core.esupports.metagen'] = {
        config = {
          type = 'empty',
        },
      },
      ['core.dirman'] = {
        config = {
          workspaces = {
            my_ws = '~/neorg', -- Format: <name_of_workspace> = <path_to_workspace_root>
          },
          index = 'index.norg',
          default_workspace = 'my_ws',
        },
      },
    },
  },
  keys = {
    { '<leader>nn', '<Plug>(neorg.dirman.new-note)', desc = 'Create Note (Neorg)' },
    { '<CR>', '<Plug>(neorg.esupports.hop.hop-link)', desc = 'Follow link', ft = 'norg' },
    { '<leader>Ta', '<Plug>(neorg.qol.todo-items.todo.task-ambiguous)', desc = 'Task ambiguous', ft = 'norg' },
    { '<leader>Td', '<Plug>(neorg.qol.todo-items.todo.task-done)', desc = 'Task done', ft = 'norg' },
    { '<leader>Tu', '<Plug>(neorg.qol.todo-items.todo.task-undone)', desc = 'Task undone', ft = 'norg' },
    { '<leader>Tp', '<Plug>(neorg.qol.todo-items.todo.task-pending)', desc = 'Task pending', ft = 'norg' },
    { '<leader>Th', '<Plug>(neorg.qol.todo-items.todo.task-on-hold)', desc = 'Task on hold', ft = 'norg' },
    { '<leader>Tc', '<Plug>(neorg.qol.todo-items.todo.task-cancelled)', desc = 'Task cancelled', ft = 'norg' },
    { '<leader>Tr', '<Plug>(neorg.qol.todo-items.todo.task-recurring)', desc = 'Task recurring', ft = 'norg' },
    { '<leader>Ti', '<Plug>(neorg.qol.todo-items.todo.task-important)', desc = 'Task important', ft = 'norg' },
    { '<C-Space>', '<Plug>(neorg.qol.todo-items.todo.task-cycle)', desc = 'Cycle task state', ft = 'norg' },
    { '<leader>TR', '<Plug>(neorg.qol.todo-items.todo.task-cycle-reverse)', desc = 'Cycle task state reverse', ft = 'norg' },

    { '>>', '<Plug>(neorg.promo.promote.nested)', mode = { 'n', 'v' }, desc = 'Promote item (recursive)', ft = 'norg' },
    { '<<', '<Plug>(neorg.promo.demote.nested)', mode = { 'n', 'v' }, desc = 'Demote item (recursive)', ft = 'norg' },
    { '>.', '<Plug>(neorg.promo.promote)', desc = 'Promote item', ft = 'norg' },
    { '<,', '<Plug>(neorg.promo.demote)', desc = 'Demote item', ft = 'norg' },

    { '<leader>ns', '<cmd>Neorg generate-workspace-summary<CR>', desc = 'Generate Summary', ft = 'norg' },
    { '<leader>nm', '<cmd>Neorg inject-metadata<CR>', desc = 'Generate metadata', ft = 'norg' },

    {
      '<leader>njd',
      function()
        vim.cmd 'Neorg journal today'
        vim.cmd 'Neorg inject-metadata'
      end,
      desc = 'Create journal (Today)',
    },
    {
      '<leader>njt',
      function()
        vim.cmd 'Neorg journal tomorrow'
        vim.cmd 'Neorg inject-metadata'
      end,
      desc = 'Create journal (Tommorow)',
    },
    {
      '<leader>njy',
      function()
        vim.cmd 'Neorg journal yesterday'
        vim.cmd 'Neorg inject-metadata'
      end,
      desc = 'Create journal (Yesterday)',
    },
    {
      '<leader>njc',
      function()
        -- Listen for the journal file to be opened BEFORE launching the calendar
        vim.api.nvim_create_autocmd('BufEnter', {
          pattern = '*.norg',
          once = true,
          callback = function()
            vim.schedule(function() vim.cmd 'Neorg inject-metadata' end)
          end,
        })

        vim.cmd 'Neorg journal custom'
      end,
      desc = 'Create journal (Calendar)',
    },
  },
}
