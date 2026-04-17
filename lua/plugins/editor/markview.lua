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
    local presets = require 'markview.presets'
    require('markview.extras.headings').setup()
    require('markview.extras.checkboxes').setup {
      --- Default checkbox state(used when adding checkboxes).
      ---@type string
      default = 'X',

      --- Changes how checkboxes are removed.
      ---@type
      ---| "disable" Disables the checkbox.
      ---| "checkbox" Removes the checkbox.
      ---| "list_item" Removes the list item markers too.
      remove_style = 'disable',

      --- Various checkbox states.
      ---
      --- States are in sets to quickly change between them
      --- when there are a lot of states.
      ---@type string[][]
      states = {
        { ' ', '/', 'X' },
        { '<', '>' },
        { '?', '!', '*' },
        { '"' },
        { 'l', 'b', 'i' },
        { 'S', 'I' },
        { 'p', 'c' },
        { 'f', 'k', 'w' },
        { 'u', 'd' },
      },
    }
    require('markview').setup {
      preview = {
        enable = true,

        enable_hybrid_mode = false,
        -- `raw_preview` causes elements to render both raw text and rendered preview for elements not included in the list.
        --  issue: https://github.com/OXY2DEV/markview.nvim/issues/487
        -- raw_previews = {
        --   markdown = { 'headings' },
        -- },
        hybrid_modes = { 'n' },
      },
      markdown = {
        -- headings = presets.headings.glow_center,

        tables = presets.tables.rounded,

        code_blocks = {
          enable = true,

          border_hl = 'MarkviewCode',
          info_hl = 'MarkviewCodeInfo',

          label_direction = 'left',
          label_hl = nil,

          min_width = 60,
          pad_amount = 2,
          pad_char = ' ',

          default = {
            block_hl = 'MarkviewCode',
            pad_hl = 'MarkviewCode',
          },

          ['diff'] = {
            block_hl = function(_, line)
              if line:match '^%+' then
                return 'MarkviewPalette4'
              elseif line:match '^%-' then
                return 'MarkviewPalette1'
              else
                return 'MarkviewCode'
              end
            end,
            pad_hl = 'MarkviewCode',
          },

          style = 'block',
          sign = true,
        },
      },
    }
  end,
  keys = {
    { '<leader>mhi', '<cmd>Heading increase<CR>', desc = 'Heading Increase (markview)' },

    { '<leader>mhd', '<cmd>Heading decrease<CR>', desc = 'Heading Increase (markview)' },
  },
}
