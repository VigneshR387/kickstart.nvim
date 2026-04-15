return {
  'nvim-neorg/neorg',
  enabled = false,
  lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
  version = '*', -- Pin Neorg to the latest stable release
  config = true,
  dependencies = {
    'nvim-neorg/tree-sitter-norg',
    'nvim-neorg/tree-sitter-norg-meta',
    { 'pysan3/neorg-templates', dependencies = { 'L3MON4D3/LuaSnip' } }, -- ADD THIS LINE
  },
  opts = {
    load = {
      ['core.defaults'] = {},
      ['core.concealer'] = {},
      ['core.export'] = {},
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
      ['external.templates'] = {
        default_subcommand = 'load', -- asks confirmation, or use "fload" to skip
        templates_dir = vim.fn.stdpath 'config' .. '/templates/norg',
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

    { '<leader>nlt', '<Plug>(neorg.pivot.list.toggle)', desc = 'Toggle list type', ft = 'norg' },
    { '<leader>nli', '<Plug>(neorg.pivot.list.invert)', desc = 'Invert list type', ft = 'norg' },

    { '>>', '<Plug>(neorg.promo.promote.nested)', mode = { 'n', 'v' }, desc = 'Promote item (recursive)', ft = 'norg' },
    { '<<', '<Plug>(neorg.promo.demote.nested)', mode = { 'n', 'v' }, desc = 'Demote item (recursive)', ft = 'norg' },
    { '>.', '<Plug>(neorg.promo.promote)', desc = 'Promote item', ft = 'norg' },
    { '<,', '<Plug>(neorg.promo.demote)', desc = 'Demote item', ft = 'norg' },

    { '<leader>ns', '<cmd>Neorg generate-workspace-summary<CR>', desc = 'Generate Summary', ft = 'norg' },
    { '<leader>nm', '<cmd>Neorg inject-metadata<CR>', desc = 'Generate metadata', ft = 'norg' },
    { '<leader>no', '<cmd>Neorg toc right<CR>', desc = 'Neorg TOC', ft = 'norg' },
    { '<leader>nc', '<Plug>(neorg.looking-glass.magnify-code-block)', desc = 'Magnify code block', ft = 'norg' },

    { '<leader>njd', '<cmd>Neorg journal today<CR>', desc = 'Create journal (Today)' },
    { '<leader>njt', '<cmd>Neorg journal tomorrow<CR>', desc = 'Create journal (Tommorow)' },
    { '<leader>njy', '<cmd>Neorg journal yesterday<CR>', desc = 'Create journal (Yesterday)' },
    { '<leader>njc', '<cmd>Neorg journal calendar<CR>', desc = 'Create journal (Calendar)' },

    { '<leader>nid', '<Plug>(neorg.tempus.insert-date)', desc = 'Insert date', ft = 'norg' },

    { '<leader>nef', '<cmd>Neorg export to-file<CR>', desc = 'Export to file', ft = 'norg' },
    { '<leader>ned', '<cmd>Neorg export directory<CR>', desc = 'Export directory', ft = 'norg' },
    { '<leader>nec', '<cmd>Neorg export to-clipboard markdown<CR>', desc = 'Export to clipboard', ft = 'norg' },

    {
      '<leader>nw',
      function()
        vim.cmd 'Neorg workspace my_ws'
        vim.schedule(function()
          local buf = vim.api.nvim_get_current_buf()
          Util.root.cache[buf] = nil
          -- bypass lsp, only look for index.norg
          local roots = Util.root.detect {
            buf = buf,
            spec = { { 'index.norg' } },
            all = false,
          }
          local root = roots[1] and roots[1].paths[1] or vim.uv.cwd()
          vim.cmd('cd ' .. root)
        end)
      end,
      desc = 'Load workspace',
    },

    {
      '<M-i>',
      function()
        local cursor_pos = vim.api.nvim_win_get_cursor(0)
        local row, _ = cursor_pos[1], cursor_pos[2]
        local line = vim.api.nvim_get_current_line()

        -- 1) If line is empty => replace it with "- ( ) " and set cursor after the parens
        if line:match '^%s*$' then
          local final_line = '- ( ) '
          vim.api.nvim_set_current_line(final_line)
          -- "- ( ) " is 6 characters
          vim.api.nvim_win_set_cursor(0, { row, 6 })
          return
        end

        -- 2) Check if line already has a bullet with possible indentation: e.g. "  - Something"
        --    Capture indentation + bullet as `bullet`, rest as `text`
        local bullet, text = line:match '^([%s]*[-*]%s+)(.*)$'
        if bullet then
          -- Convert bullet => bullet .. "( ) " .. text
          local final_line = bullet .. '( ) ' .. text
          vim.api.nvim_set_current_line(final_line)
          -- Place cursor right after "( ) " => bullet_len + 4 (0-based)
          local bullet_len = #bullet
          vim.api.nvim_win_set_cursor(0, { row, bullet_len + 4 })
          return
        end

        -- 3) Plain text line, no bullet => prepend "- ( ) "
        local final_line = '- ( ) ' .. line
        vim.api.nvim_set_current_line(final_line)
        -- "- ( ) " is 6 characters
        vim.api.nvim_win_set_cursor(0, { row, 6 })
      end,
      mode = { 'n', 'v' },
      ft = 'norg',
      desc = 'Convert bullet to a neorg task or insert new task bullet',
    },
    {
      '<M-x>',
      function() Util.neorg.task_toggle() end,
      desc = 'Toggle neorg task and move it to done',
      ft = 'norg',
    },
  },
}
