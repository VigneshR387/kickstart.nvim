-- Filename: ~/.config/nvim/lua/plugins/ui/nvim-treesitter-context.lua
-- ~/.config/nvim/lua/plugins/ui/nvim-treesitter-context.lua
--
-- Link to github repo:
-- https://github.com/nvim-treesitter/nvim-treesitter-context

-- Show context of the current function
return {
  'nvim-treesitter/nvim-treesitter-context',
  event = 'LazyFile',
  opts = function()
    local tsc = require 'treesitter-context'
    Snacks.toggle({
      name = 'Treesitter Context',
      get = tsc.enabled,
      set = function(state)
        if state then
          tsc.enable()
        else
          tsc.disable()
        end
      end,
    }):map '<leader>ut'
    return { mode = 'cursor', max_lines = 3 }
  end,
}
