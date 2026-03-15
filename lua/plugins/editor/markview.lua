-- Filename: ~/.config/nvim/lua/plugins/editor/markview.lua
-- ~/.config/nvim/lua/plugins/editor/markview.lua
--
-- Link to github repo:
-- https://github.com/OXY2DEV/markview.nvim

return {
  'OXY2DEV/markview.nvim',
  enabled = true,
  event = 'LazyFile',
  opts = function()
    require('markview').setup {
      markdown = {
        headings = { presets = { headings = glow } },
      },
    }
  end,
}
