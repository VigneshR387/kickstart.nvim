-- Collection of various small independent plugins/modules
return {
  'nvim-mini/mini.nvim',
  config = function()
    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
    --  - ci'  - [C]hange [I]nside [']quote
    require('mini.ai').setup { n_lines = 500 }

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup {
      mappings = {
        add = 'sa', -- Add surrounding in Normal and Visual modes
        delete = 'sd', -- Delete surrounding
        find = 'sf', -- Find surrounding (to the right)
        find_left = 'sF', -- Find surrounding (to the left)
        highlight = 'sh', -- Highlight surrounding
        replace = 'sr', -- Replace surrounding

        suffix_last = 'l', -- Suffix to search with "prev" method
        suffix_next = 'n', -- Suffix to search with "next" method
      },
    }
    -- LUA: lua only accepts positional args and single table inside a function call eg:require('lua').setup(<only pos args & single table>)
    require('mini.pairs').setup {
      modes = { insert = true, command = false, terminal = false },
    }
    -- Allow auto pairing for special characters like '{',''','"' etc.
    require('mini.icons').setup {

      -- Icon style: 'glyph' or 'ascii'
      style = 'glyph',
    }
    -- Provide icons with their highlighting via a single MiniIcons.get() for various categories: filetype, file/directory path, extension, operating system, LSP kind values. Icons and category defaults can be overridden.

    --  Check out: https://github.com/nvim-mini/mini.nvim
  end,
}
