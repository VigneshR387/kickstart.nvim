return {
  'romgrk/barbar.nvim',
  event = 'LazyFile',
  dependencies = {
    'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
  },
  init = function() vim.g.barbar_auto_setup = false end,
  opts = {
    -- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
    -- animation = true,
    -- insert_at_start = true,
    -- …etc.
    icons = {
      pinned = { button = '', filename = true },
    },
  },
  -- version = '^1.0.0', -- optional: only update when a new 1.x version is released

  keys = {
    { '<leader>bp', '<Cmd>BufferPin<CR>', desc = 'Toggle Pin' },
    { '<leader>bP', '<Cmd>BufferCloseAllButPinned<CR>', desc = 'Delete Non-Pinned Buffers' },

    { '<leader>br', '<Cmd>BufferCloseBuffersRight<CR>', desc = 'Delete Buffers to the Right' },
    { '<leader>bl', '<Cmd>BufferCloseBuffersLeft<CR>', desc = 'Delete Buffers to the Left' },

    { '<S-h>', '<Cmd>BufferPrevious<CR>', desc = 'Prev Buffer' },
    { '<S-l>', '<Cmd>BufferNext<CR>', desc = 'Next Buffer' },

    { '[b', '<Cmd>BufferPrevious<CR>', desc = 'Prev Buffer' },
    { ']b', '<Cmd>BufferNext<CR>', desc = 'Next Buffer' },

    { '[B', '<Cmd>BufferMovePrevious<CR>', desc = 'Move Buffer Prev' },
    { ']B', '<Cmd>BufferMoveNext<CR>', desc = 'Move Buffer Next' },

    { '<leader>bd', '<Cmd>BufferClose<CR>', desc = 'Close Buffer' },
    { '<leader>bo', '<Cmd>BufferCloseAllButCurrent<CR>', desc = 'Close Other Buffers' },

    { '<leader>bj', '<Cmd>BufferPick<CR>', desc = 'Pick Buffer' },
    { '<leader>bD', '<Cmd>BufferPickDelete<CR>', desc = 'Pick Buffer to Delete' },

    -- Goto pinned/unpinned buffer
    -- { "<leader>bP", "<Cmd>BufferGotoPinned<CR>", desc = "Goto Pinned Buffer" },
    -- { "<leader>bU", "<Cmd>BufferGotoUnpinned<CR>", desc = "Goto Unpinned Buffer" },

    -- Wipeout buffer
    -- { "<leader>bW", "<Cmd>BufferWipeout<CR>", desc = "Wipeout Buffer" },

    -- Close commands
    -- { "<leader>bo", "<Cmd>BufferCloseAllButCurrent<CR>", desc = "Close Other Buffers" },
    -- { "<leader>bP", "<Cmd>BufferCloseAllButPinned<CR>", desc = "Close All But Pinned" },
    -- { "<leader>bO", "<Cmd>BufferCloseAllButCurrentOrPinned<CR>", desc = "Close Others Except Pinned" },
    -- { "<leader>bh", "<Cmd>BufferCloseBuffersLeft<CR>", desc = "Close Buffers to the Left" },
    -- { "<leader>bl", "<Cmd>BufferCloseBuffersRight<CR>", desc = "Close Buffers to the Right" },

    -- Sort automatically by...
    -- { "<leader>bb", "<Cmd>BufferOrderByBufferNumber<CR>", desc = "Sort by Buffer Number" },
    -- { "<leader>bn", "<Cmd>BufferOrderByName<CR>", desc = "Sort by Name" },
    -- { "<leader>bd", "<Cmd>BufferOrderByDirectory<CR>", desc = "Sort by Directory" },
    -- { "<leader>bl", "<Cmd>BufferOrderByLanguage<CR>", desc = "Sort by Language" },
    -- { "<leader>bw", "<Cmd>BufferOrderByWindowNumber<CR>", desc = "Sort by Window Number" },

    -- Other:
    -- :BarbarEnable - enables barbar (enabled by default)
    -- :BarbarDisable - very bad command, should never be used
  },
}
