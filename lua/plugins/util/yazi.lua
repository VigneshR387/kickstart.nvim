---@type LazySpec
return {
  'mikavilpas/yazi.nvim',
  enabled = true,
  version = '*', -- use the latest stable version
  event = 'VeryLazy',
  dependencies = {
    { 'nvim-lua/plenary.nvim', lazy = true },
  },
  keys = {
    -- 👇 in this section, choose your own keymappings!
    {
      '<leader>e',
      mode = { 'n', 'v' },
      '<cmd>Yazi<cr>',
      desc = 'Explorer Yazi (cwd dir)',
    },
    {
      '<leader>fe',
      mode = { 'n', 'v' },
      '<cmd>Yazi<cr>',
      desc = 'Explorer Yazi (cwd dir)',
    },
    {
      '<leader>E',
      mode = { 'n', 'v' },
      function()
        local root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
        if vim.v.shell_error ~= 0 then
          root = vim.fn.getcwd() -- fallback to cwd if not in a git repo
        end
        require('yazi').yazi(nil, root)
      end,
      desc = 'Explorer Yazi (root)',
    },
    {
      '<leader>fE',
      mode = { 'n', 'v' },
      function()
        local git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
        if vim.v.shell_error ~= 0 then git_root = vim.fn.getcwd() end
        require('yazi').yazi(nil, git_root)
      end,
      desc = 'Explorer Yazi (root)',
    },
    {
      '<c-up>',
      '<cmd>Yazi toggle<cr>',
      desc = 'Resume the last yazi session',
    },
  },
  ---@type YaziConfig | {}
  opts = {
    -- if you want to open yazi instead of netrw, see below for more info
    open_for_directories = false,
    keymaps = {
      show_help = '<f2>',
    },
  },
  -- 👇 if you use `open_for_directories=true`, this is recommended
  init = function()
    -- mark netrw as loaded so it's not loaded at all.
    --
    -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
    vim.g.loaded_netrwPlugin = 1
  end,
}
