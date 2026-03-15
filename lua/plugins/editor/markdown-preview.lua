-- Filename: ~/.config/nvim/lua/plugins/editor/markdown-preview.lua
-- ~/.config/nvim/lua/plugins/editor/markdown-preview.lua
--
-- Link to github repo:
-- https://github.com/iamcco/markdown-preview.nvim

return {
  'iamcco/markdown-preview.nvim',
  enabled = true,
  cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  build = function()
    require('lazy').load { plugins = { 'markdown-preview.nvim' } }
    vim.fn['mkdp#util#install']()
  end,
  keys = {
    {
      '<leader>mp',
      ft = 'markdown',
      '<cmd>MarkdownPreviewToggle<cr>',
      desc = 'Markdown Preview',
    },
  },
  config = function() vim.cmd [[do FileType]] end,
}
