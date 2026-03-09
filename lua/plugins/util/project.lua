local dep = nil
local pick = nil
if Util.has 'telescope.nvim' then
  dep = { 'nvim-telescope/telescope.nvim', dependencies = { 'nvim-lua/plenary.nvim' } }
elseif Util.has 'picker.nvim' then
  dep = 'wsdjeg/picker.nvim'
  pick = {
    picker = {
      enabled = true,
      sort = 'newest', -- 'newest' or 'oldest'
      hidden = false, -- Show hidden files
    },
  }
elseif Util.has 'fzf-lua' then
  dep = 'ibhagwan/fzf-lua'
elseif Util.has 'snacks.nvim' then
  dep = 'folke/snacks.nvim'
  pick = {
    snacks = {
      enabled = true, -- Will enable the `:ProjectSnacks` command
      opts = {
        sort = 'newest',
        hidden = false,
        title = 'Select Project',
        layout = 'select',
        -- icon = {},
        -- path_icons = {},
      },
    },
  }
else
  vim.notify 'No picker found. Installing and using Snacks.picker'
  dep = 'folke/snacks.nvim'
end
return {
  {
    'DrKJeff16/project.nvim',
    cmd = { -- Lazy-load by commands
      'Project',
      'ProjectAdd',
      'ProjectConfig',
      'ProjectDelete',
      'ProjectExport',

      'ProjectHealth',
      'ProjectHistory',
      'ProjectImport',
      'ProjectLog', -- If logging is enabled

      'ProjectRecents',
      'ProjectRoot',
      'ProjectSession',
      'ProjectSnacks', -- If using `snacks.nvim` integration
    },
    dependencies = { dep },
    opts = pick,
    keys = {
      { '<leader>fp', '<cmd>ProjectSnacks<CR>', desc = 'Project' },
      { '<leader>fP', '<cmd>Project<CR>', desc = 'project Menu' },
    },
  },
  {
    'folke/snacks.nvim',
    optional = true,
    opts = function(_, opts)
      table.insert(opts.dashboard.preset.keys, 3, {
        action = ':ProjectSnacks',
        desc = 'Projects',
        icon = ' ',
        key = 'p',
      })
    end,
  },
}
