return {
  'nvim-mini/mini.pairs',
  event = 'VeryLazy',
  opts = {
    modes = { insert = true, command = true, terminal = false },
    -- skip autopair when next character is one of these
    skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
    -- skip autopair when the cursor is inside these treesitter nodes
    skip_ts = { 'string' },
    -- skip autopair when next character is closing pair
    -- and there are more closing pairs than opening pairs
    skip_unbalanced = true,
    -- better deal with markdown code blocks
    markdown = true,
  },
  -- LUA:
  -- lazy.nvim runs this function after the plugin loads.
  -- It calls: config(plugin, opts)
  -- `_` receives the plugin spec (unused here).
  -- `opts` contains the merged options from the `opts` table above.
  -- We pass those options to our util module, which then calls
  -- `require("mini.pairs").setup(opts)` internally.

  config = function(_, opts)
    Util.mini.pairs(opts) 
  end,
}
