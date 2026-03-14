-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- Smart paste for images with filetype check

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown', 'org', 'tex', 'html', 'typst', 'rst', 'asciidoc', 'wiki' },
  callback = function(ev)
    local function paste()
      local pasted = require('img-clip').paste_image()
      if not pasted then vim.cmd(string.format('normal! "%s%dp', vim.v.register, vim.v.count1)) end
    end

    vim.keymap.set('n', 'p', paste, { buffer = ev.buf, noremap = true, silent = true })
  end,
})

-- Auto toggle Spell check when in the listed filetypes
local function augroup(name) return vim.api.nvim_create_augroup('spell' .. name, { clear = true }) end
-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd('FileType', {
  group = augroup 'wrap_spell',
  pattern = { 'text', 'plaintex', 'typst', 'gitcommit', 'markdown' },
  callback = function()
    -- -- By default wrap is set to true regardless of what I chose in my options.lua file,
    -- -- This sets wrapping for my skitty-notes and I don't want to have
    -- -- wrapping there, I want to decide this in the options.lua file
    -- vim.opt_local.wrap = false
    vim.opt_local.spell = true
  end,
})

