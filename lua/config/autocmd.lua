-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- NOTE: Disabled in favor of yanky
--
-- -- Highlight when yanking (copying) text
-- --  Try it with `yap` in normal mode
-- --  See `:help vim.hl.on_yank()`
-- vim.api.nvim_create_autocmd('TextYankPost', {
--   desc = 'Highlight when yanking (copying) text',
--   group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
--   callback = function() vim.hl.on_yank() end,
-- })

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

-- close some filetypes with <q>
vim.api.nvim_create_autocmd('FileType', {
  group = augroup 'close_with_q',
  pattern = {
    'PlenaryTestPopup',
    'checkhealth',
    'dbout',
    'gitsigns-blame',
    'grug-far',
    'help',
    'lspinfo',
    'neotest-output',
    'neotest-output-panel',
    'neotest-summary',
    'notify',
    'qf',
    'spectre_panel',
    'startuptime',
    'tsplayground',
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set('n', 'q', function()
        vim.cmd 'close'
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = 'Quit buffer',
      })
    end)
  end,
})

-- -- Enable LSP codelens auto-refresh only for markdown buffers
-- -- Keeps LazyVim global codelens disabled, but gives markdown-oxide its reference count lenses automatically
local function codelens_supported(bufnr)
  for _, c in ipairs(vim.lsp.get_clients { bufnr = bufnr }) do
    if c.server_capabilities and c.server_capabilities.codeLensProvider then return true end
  end
  return false
end
-- Refresh codelens only when the current buffer is markdown and the attached client supports it
local function refresh_markdown_codelens(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  if vim.bo[bufnr].buftype ~= '' then return end
  if vim.bo[bufnr].filetype ~= 'markdown' then return end
  if not codelens_supported(bufnr) then return end
  vim.lsp.codelens.refresh { bufnr = bufnr }
end
-- Create markdown-only codelens refresh triggers
vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave', 'TextChanged' }, {
  callback = function(args) refresh_markdown_codelens(args.buf) end,
})

-- Auto fold markdown headings to level 2 when markdown file is opened
vim.api.nvim_create_autocmd('BufRead', {
  pattern = '*.md',
  callback = function()
    -- Get the full path of the current file
    local file_path = vim.fn.expand '%:p'
    -- Ignore files in my daily note directory
    if file_path:match(os.getenv 'HOME' .. '/github/obsidian_main/250%-daily/') then return end -- Avoid running zk multiple times for the same buffer
    if vim.b.zk_executed then return end
    vim.b.zk_executed = true -- Mark as executed
    -- Use `vim.defer_fn` to add a slight delay before executing `zk`
    vim.defer_fn(function()
      vim.cmd 'normal zk'
      -- This write was disabling my inlay hints
      -- vim.cmd("silent write")
      vim.notify('Folded keymaps', vim.log.levels.INFO)
    end, 100) -- Delay in milliseconds (100ms should be enough)
  end,
})

-- Auto setup folding for markdown
-- Checks each line to see if it matches a markdown heading (#, ##, etc.):
-- It’s called implicitly by Neovim’s folding engine by vim.opt_local.foldexpr
function _G.markdown_foldexpr()
  local lnum = vim.v.lnum
  local line = vim.fn.getline(lnum)
  local heading = line:match '^(#+)%s'
  if heading then
    local level = #heading
    if level == 1 then
      -- Special handling for H1
      if lnum == 1 then
        return '>1'
      else
        local frontmatter_end = vim.b.frontmatter_end
        if frontmatter_end and (lnum == frontmatter_end + 1) then return '>1' end
      end
    elseif level >= 2 and level <= 6 then
      -- Regular handling for H2-H6
      return '>' .. level
    end
  end
  return '='
end
-- Use autocommand to apply only to markdown files
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = Util.markdown.set_markdown_folding,
})
