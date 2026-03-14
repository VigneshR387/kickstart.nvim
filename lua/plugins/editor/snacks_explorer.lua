local root = require 'util.root'
return {
  'folke/snacks.nvim',
  priority = 1000,
  opts = {
    explorer = {
      enabled = true,
      replace_netrw = true, -- Replace netrw with the snacks explorer
      trash = true, -- Use the system trash when deleting files
      git_status = true,
      diagnostics = true,
      win = {

        list = {

          keys = {
            ['h'] = 'explorer_up',
            ['l'] = 'confirm',
            ['c'] = 'explorer_close', -- close directory
            ['a'] = 'explorer_add',
            ['d'] = 'explorer_del',
            ['r'] = 'explorer_rename',
            ['Y'] = 'explorer_copy',
            ['x'] = 'explorer_move',
            ['o'] = 'explorer_open', -- open with system application
            ['P'] = 'toggle_preview',
            ['y'] = { 'explorer_yank', mode = { 'n', 'x' } },
            ['p'] = 'explorer_paste',
            ['u'] = 'explorer_update',
            ['<c-c>'] = 'tcd',
            ['<leader>/'] = 'picker_grep',
            ['<c-t>'] = 'terminal',
            ['.'] = 'explorer_focus',
            ['I'] = 'toggle_ignored',
            ['H'] = 'toggle_hidden',
            ['Z'] = 'explorer_close_all',
            [']g'] = 'explorer_git_next',
            ['[g'] = 'explorer_git_prev',
            [']d'] = 'explorer_diagnostic_next',
            ['[d'] = 'explorer_diagnostic_prev',
            [']w'] = 'explorer_warn_next',
            ['[w'] = 'explorer_warn_prev',
            [']e'] = 'explorer_error_next',
            ['[e'] = 'explorer_error_prev',
          },
        },
      },
    },
  },
  keys = {
    {
      '<leader>fe',
      desc = 'Explorer Snacks (cwd)',
      function()
        local explorer = Snacks.picker.get({ source = 'explorer' })[1]

        if explorer then
          explorer:focus()
        else
          Snacks.explorer()
        end
      end,
    },
    {
      '<leader>fE',
      desc = 'Explorer Snacks (root)',
      function()
        local explorer = Snacks.picker.get({ source = 'explorer' })[1]

        if explorer then
          explorer:focus()
        else
          Snacks.explorer { cwd = root() }
        end
      end,
    },
    { '<leader>e', '<leader>fe', desc = 'Explorer Snacks (root dir)', remap = true },
    { '<leader>E', '<leader>fE', desc = 'Explorer Snacks (cwd)', remap = true },
  },
}
