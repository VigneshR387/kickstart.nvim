return {
  {
    'stevearc/overseer.nvim',
    cmd = {
      'OverseerOpen',
      'OverseerClose',
      'OverseerToggle',
      'OverseerRun',
      'OverseerTaskAction',
    },
    opts = {
      dap = false,
      task_list = {
        keymaps = {
          ['<C-j>'] = false,
          ['<C-k>'] = false,
        },
      },
      form = {
        win_opts = {
          winblend = 0,
        },
      },
      confirm = {
        win_opts = {
          winblend = 0,
        },
      },
      task_win = {
        win_opts = {
          winblend = 0,
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>Ow", "<cmd>OverseerToggle!<cr>",    desc = "Task list" },
      { "<leader>Oo", "<cmd>OverseerRun<cr>",        desc = "Run task" },
      { "<leader>Ot", "<cmd>OverseerTaskAction<cr>", desc = "Task action" },
    },
  },
  {
    'folke/edgy.nvim',
    optional = true,
    opts = function(_, opts)
      opts.right = opts.right or {}
      table.insert(opts.right, {
        title = 'Overseer',
        ft = 'OverseerList',
        open = function() require('overseer').open() end,
      })
    end,
  },
  {
    'nvim-neotest/neotest',
    optional = true,
    opts = function(_, opts)
      opts = opts or {}
      opts.consumers = opts.consumers or {}
      opts.consumers.overseer = require 'neotest.consumers.overseer'
    end,
  },
  {
    'mfussenegger/nvim-dap',
    optional = true,
    opts = function() require('overseer').enable_dap() end,
  },
}
