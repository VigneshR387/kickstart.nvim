-- Highlight todo, notes, etc in comments
return {
  'folke/todo-comments.nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    signs = false,
    keywords = {
      LUA = { icon = '', color = '#5353c9', fg = 'FIX' },
    },
  },
  keys = {
    { '<leader>st', function() Snacks.picker.todo_comments() end, desc = 'Todo' },
    { '<leader>sT', function() Snacks.picker.todo_comments { keywords = { 'TODO', 'FIX', 'FIXME' } } end, desc = 'Todo/Fix/Fixme' },
  },
}
