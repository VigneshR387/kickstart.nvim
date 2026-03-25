-- [[ Basic Keymaps ]]
--  See `:help map()`
local root = require 'util.root'
local map = Snacks.keymap.set
-- Clear highlights on search when pressing <Esc> in normal mode

--  See `:help hlsearch`
map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Escape and Clear hlsearch' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
-- WARN: CAUSING ISSUES WITH YAZI.NVIM

-- map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- map('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- map('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- map('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- map('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- map("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- map("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- map("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- map("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- Move to window using the <ctrl> hjkl keys
map('n', '<C-h>', '<C-w>h', { desc = 'Go to Left Window', remap = true })
map('n', '<C-j>', '<C-w>j', { desc = 'Go to Lower Window', remap = true })
map('n', '<C-k>', '<C-w>k', { desc = 'Go to Upper Window', remap = true })
map('n', '<C-l>', '<C-w>l', { desc = 'Go to Right Window', remap = true })

-- Resize window using <ctrl> arrow keys
map('n', '<C-Up>', '<cmd>resize +2<cr>', { desc = 'Increase Window Height' })
map('n', '<C-Down>', '<cmd>resize -2<cr>', { desc = 'Decrease Window Height' })
map('n', '<C-Left>', '<cmd>vertical resize -2<cr>', { desc = 'Decrease Window Width' })
map('n', '<C-Right>', '<cmd>vertical resize +2<cr>', { desc = 'Increase Window Width' })

-- better up/down
map({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
map({ 'n', 'x' }, '<Down>', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
map({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })
map({ 'n', 'x' }, '<Up>', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })

-- lazy
map('n', '<leader>l', '<cmd>Lazy<cr>', { desc = 'Lazy' })

--keywordprg
map('n', '<leader>K', '<cmd>norm! K<cr>', { desc = 'Keywordprg' })

-- new file
map('n', '<leader>fn', '<cmd>enew<cr>', { desc = 'New File' })

-- Toggle executable permission on current file, previously I had 2 keymaps, to
-- add or remove exec permissions, now it's a toggle using the same keymap
map('n', '<leader>fx', function()
  local file = vim.fn.expand '%'
  local perms = vim.fn.getfperm(file)
  local is_executable = string.match(perms, 'x', -1) ~= nil
  local escaped_file = vim.fn.shellescape(file)
  if is_executable then
    vim.cmd('silent !chmod -x ' .. escaped_file)
    vim.notify('Removed executable permission', vim.log.levels.INFO)
  else
    vim.cmd('silent !chmod +x ' .. escaped_file)
    vim.notify('Added executable permission', vim.log.levels.INFO)
  end
end, { desc = 'Toggle executable permission' })

-- Keymap to delete the current file
map('n', '<leader>fD', function() Util.file.delete_current_file() end, { desc = '[P]Delete current file' })

-- file-details
-- comments file location and  repo link if  its a plugin at the top of file
map({ 'n', 'v', 'i' }, '<M-z>', function() Util.file.file_detail() end, { desc = 'Insert filename header with plugin link' })

-- Keymaps for copying file path to clipboard
-- map("n", "<leader>fp", copy_filepath_to_clipboard, { desc = "[P]Copy file path to clipboard" })
-- I couldn't use <M-p> because its used for previous reference
map({ 'n', 'v', 'i' }, '<M-c>', function() Util.file.copy_filepath_to_clipboard() end, { desc = '[P]Copy file path to clipboard' })

-- better indenting
map('x', '<', '<gv')
map('x', '>', '>gv')

-- quit
map('n', '<leader>qq', '<cmd>qa<cr>', { desc = 'Quit All' })

-- buffers
map('n', '<S-h>', '<cmd>bprevious<cr>', { desc = 'Prev Buffer' })
map('n', '<S-l>', '<cmd>bnext<cr>', { desc = 'Next Buffer' })
map('n', '[b', '<cmd>bprevious<cr>', { desc = 'Prev Buffer' })
map('n', ']b', '<cmd>bnext<cr>', { desc = 'Next Buffer' })
map('n', '<leader>bb', '<cmd>e #<cr>', { desc = 'Switch to Other Buffer' })
map('n', '<leader>`', '<cmd>e #<cr>', { desc = 'Switch to Other Buffer' })
map('n', '<leader>bd', function() Snacks.bufdelete() end, { desc = 'Delete Buffer' })
map('n', '<leader>bo', function() Snacks.bufdelete.other() end, { desc = 'Delete Other Buffers' })
map('n', '<leader>bD', '<cmd>:bd<cr>', { desc = 'Delete Buffer and Window' })

-- highlights under cursor
map('n', '<leader>ui', vim.show_pos, { desc = 'Inspect Pos' })
map('n', '<leader>uI', function()
  vim.treesitter.inspect_tree()
  vim.api.nvim_input 'I'
end, { desc = 'Inspect Tree' })
-- lua
map({ 'n', 'x' }, '<leader>R', function() Snacks.debug.run() end, { desc = 'Run Lua', ft = 'lua' })

-- git
if vim.fn.executable 'lazygit' == 1 then
  map('n', '<leader>gg', function() Snacks.lazygit { cwd = root.git() } end, { desc = 'Lazygit (Root Dir)' })
  map('n', '<leader>gG', function() Snacks.lazygit() end, { desc = 'Lazygit (cwd)' })
end
map({ 'n', 'x' }, '<leader>gB', function() Snacks.gitbrowse() end, { desc = 'Git Browse (open)' })
map({ 'n', 'x' }, '<leader>gY', function()
  Snacks.gitbrowse { open = function(url) vim.fn.setreg('+', url) end, notify = false }
end, { desc = 'Git Browse (copy)' })

-- Clear search and stop snippet on escape
-- map({ 'i', 'n', 's' }, '<esc>', function()
--   vim.cmd 'noh'
--   Util.cmp.actions.snippet_stop()
--   return '<esc>'
-- end, { expr = true, desc = 'Escape and Clear hlsearch' })

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
map('n', '<leader>ur', '<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>', { desc = 'Redraw / Clear hlsearch / Diff Update' })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map('n', 'n', "'Nn'[v:searchforward].'zv'", { expr = true, desc = 'Next Search Result' })
map('x', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' })
map('o', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' })
map('n', 'N', "'nN'[v:searchforward].'zv'", { expr = true, desc = 'Prev Search Result' })
map('x', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev Search Result' })
map('o', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev Search Result' })

-- Add undo break-points
map('i', ',', ',<c-g>u')
map('i', '.', '.<c-g>u')
map('i', ';', ';<c-g>u')

-- toggle options
Util.format.snacks_toggle():map '<leader>uf'
Util.format.snacks_toggle(true):map '<leader>uF'
Snacks.toggle.option('spell', { name = 'Spelling' }):map '<leader>us'
Snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>uw'
Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map '<leader>uL'
Snacks.toggle.diagnostics():map '<leader>ud'
Snacks.toggle.line_number():map '<leader>ul'
Snacks.toggle.option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = 'Conceal Level' }):map '<leader>uc'
Snacks.toggle.option('showtabline', { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = 'Tabline' }):map '<leader>uA'
Snacks.toggle.treesitter():map '<leader>uT'
Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):map '<leader>ub'
Snacks.toggle.dim():map '<leader>uD'
Snacks.toggle.animate():map '<leader>ua'
Snacks.toggle.indent():map '<leader>ug'
Snacks.toggle.scroll():map '<leader>uS'
Snacks.toggle.zen():map '<leader>uz'
Snacks.toggle.profiler():map '<leader>dpp'
Snacks.toggle.profiler_highlights():map '<leader>dph'
if vim.lsp.inlay_hint then Snacks.toggle.inlay_hints():map '<leader>uh' end

-- windows
map('n', '<leader>-', '<C-W>s', { desc = 'Split Window Below', remap = true })
map('n', '<leader>|', '<C-W>v', { desc = 'Split Window Right', remap = true })
map('n', '<leader>wd', '<C-W>c', { desc = 'Delete Window', remap = true })
Snacks.toggle.zoom():map('<leader>wm'):map '<leader>uZ'

-- tabs
map('n', '<leader><tab>l', '<cmd>tablast<cr>', { desc = 'Last Tab' })
map('n', '<leader><tab>o', '<cmd>tabonly<cr>', { desc = 'Close Other Tabs' })
map('n', '<leader><tab>f', '<cmd>tabfirst<cr>', { desc = 'First Tab' })
map('n', '<leader><tab><tab>', '<cmd>tabnew<cr>', { desc = 'New Tab' })
map('n', '<leader><tab>]', '<cmd>tabnext<cr>', { desc = 'Next Tab' })
map('n', '<leader><tab>d', '<cmd>tabclose<cr>', { desc = 'Close Tab' })
map('n', '<leader><tab>[', '<cmd>tabprevious<cr>', { desc = 'Previous Tab' })

-- floating terminal
map('n', '<leader>fT', function() Snacks.terminal() end, { desc = 'Terminal (cwd)' })
map('n', '<leader>ft', function() Snacks.terminal(nil, { cwd = root() }) end, { desc = 'Terminal (Root Dir)' })
map({ 'n', 't' }, '<c-/>', function() Snacks.terminal(nil, { cwd = root() }) end, { desc = 'Terminal (Root Dir)' })
map({ 'n', 't' }, '<c-_>', function() Snacks.terminal(nil, { cwd = root() }) end, { desc = 'which_key_ignore' })

-- -- location list
map('n', '<leader>xl', function()
  local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not success and err then vim.notify(err, vim.log.levels.ERROR) end
end, { desc = 'Location List' })

-- quickfix list
map('n', '<leader>xq', function()
  local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not success and err then vim.notify(err, vim.log.levels.ERROR) end
end, { desc = 'Quickfix List' })

-- diagnostic
local diagnostic_goto = function(next, severity)
  return function()
    vim.diagnostic.jump {
      count = (next and 1 or -1) * vim.v.count1,
      severity = severity and vim.diagnostic.severity[severity] or nil,
      float = true,
    }
  end
end
map('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Line Diagnostics' })
map('n', ']d', diagnostic_goto(true), { desc = 'Next Diagnostic' })
map('n', '[d', diagnostic_goto(false), { desc = 'Prev Diagnostic' })
map('n', ']e', diagnostic_goto(true, 'ERROR'), { desc = 'Next Error' })
map('n', '[e', diagnostic_goto(false, 'ERROR'), { desc = 'Prev Error' })
map('n', ']w', diagnostic_goto(true, 'WARN'), { desc = 'Next Warning' })
map('n', '[w', diagnostic_goto(false, 'WARN'), { desc = 'Prev Warning' })
-- Copy the current line and all diagnostics on that line to system clipboard
map('n', 'yd', function()
  local pos = vim.api.nvim_win_get_cursor(0)
  local line_num = pos[1] - 1 -- 0-indexed
  local line_text = vim.api.nvim_buf_get_lines(0, line_num, line_num + 1, false)[1]
  local diagnostics = vim.diagnostic.get(0, { lnum = line_num })
  if #diagnostics == 0 then
    vim.notify('No diagnostic found on this line', vim.log.levels.WARN)
    return
  end
  local message_lines = {}
  for _, d in ipairs(diagnostics) do
    for msg_line in d.message:gmatch '[^\n]+' do
      table.insert(message_lines, msg_line)
    end
  end
  local formatted = {}
  table.insert(formatted, 'Line:\n' .. line_text .. '\n')
  table.insert(formatted, 'Diagnostic on that line:\n' .. table.concat(message_lines, '\n'))
  vim.fn.setreg('+', table.concat(formatted, '\n\n'))
  vim.notify('Line and diagnostic copied to clipboard', vim.log.levels.INFO)
end, { desc = '[P]Yank line and diagnostic to system clipboard' })

-- better new line
map('n', 'o', 'o<Esc>', { desc = 'New line below without insert' })
map('n', 'O', 'O<Esc>', { desc = 'New line above without insert' })

-- Disable arrow keys in all modes

map({ 'n', 'i', 'v', 'x' }, '<Up>', '<Nop>')
map({ 'n', 'i', 'v', 'x' }, '<Down>', '<Nop>')
map({ 'n', 'i', 'v', 'x' }, '<Left>', '<Nop>')
map({ 'n', 'i', 'v', 'x' }, '<Right>', '<Nop>')

-- Exit mode  keys
map('i', 'jj', '<Esc>', { noremap = false })
map('i', 'jﬂ', '<Esc>', { noremap = false })

-- Disable commandline window
map('n', 'q', '<Nop>', { noremap = true, silent = true })
-- ###########################################################################################
-- #                                    Images (BEGIN)
-- ###########################################################################################
-- Paste images
-- I tried using <C-v> but duh, that's used for visual block mode
map({ 'n', 'i' }, '<M-a>', function()
  local pasted_image = require('img-clip').paste_image()
  if pasted_image then
    -- "Update" saves only if the buffer has been modified since the last save
    vim.cmd 'silent! update'
    -- Get the current line
    local line = vim.api.nvim_get_current_line()
    -- Move cursor to end of line
    vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], #line })
    -- I reload the file, otherwise I cannot view the image after pasted
    vim.cmd 'edit!'
  end
end, { desc = '[P]Paste image from system clipboard' })

-- Keymap to paste images in the 'assets' directory
-- This pastes images for my blogpost, I need to keep them in a different directory
-- so I pass those options to img-clip
map({ 'n', 'i' }, '<M-1>', Util.markdown.process_image, { desc = "[P]Paste image 'assets' directory" })

-- Delete Image
map('n', '<leader>id', function()
  local line = vim.api.nvim_get_current_line()
  local image_pattern = '%[.-%]%((.-)%)'
  local _, _, image_path = string.find(line, image_pattern)

  if not image_path then
    print 'No image found'
    return
  end

  local current = vim.fn.expand '%:p:h'
  local path = current .. '/' .. image_path

  vim.fn.system { 'gio', 'trash', path }

  -- delete the markdown image line
  vim.cmd 'normal! dd'

  print 'Image moved to trash and line deleted'
end, {
  ft = 'markdown',
  desc = 'Delete Markdown image',
})

-- Rename image under cursor lamw25wmal
-- If the image is referenced multiple times in the file, it will also rename
-- all the other occurrences in the file
map('n', '<leader>iR', function() Util.markdown.rename_image() end, { desc = '[P]Rename image under cursor' })

-- ###########################################################################################
-- #                                    Images (END)
-- ###########################################################################################

-- ###########################################################################################
-- #                                    Markdown (BEGIN)
-- ###########################################################################################

-- Keymap for folding markdown headings of level 1 or above
map('n', 'zj', function()
  -- "Update" saves only if the buffer has been modified since the last save
  vim.cmd 'silent update'
  -- map("n", "<leader>mfj", function()
  -- Unfold everything first or I had issues
  vim.cmd 'normal! zR'
  Util.markdown.fold_markdown_headings { 6, 5, 4, 3, 2, 1 }
  vim.cmd 'normal! zz' -- center the cursor line on screen
end, { ft = 'markdown', desc = '[P]Fold all headings level 1 or above' })

-- Keymap for folding markdown headings of level 2 or above
-- I know, it reads like "madafaka" but "k" for me means "2"
map('n', 'zk', function()
  vim.cmd 'silent update'
  vim.cmd 'normal! zR'
  Util.markdown.fold_markdown_headings { 6, 5, 4, 3, 2 }
  vim.cmd 'normal! zz'
end, { ft = 'markdown', desc = '[P]Fold all headings level 2 or above' })

-- Keymap for folding markdown headings of level 3 or above
map('n', 'zl', function()
  -- "Update" saves only if the buffer has been modified since the last save
  vim.cmd 'silent update'
  -- map("n", "<leader>mfl", function()
  -- Unfold everything first or I had issues
  vim.cmd 'normal! zR'
  Util.markdown.fold_markdown_headings { 6, 5, 4, 3 }
  vim.cmd 'normal! zz' -- center the cursor line on screen
end, { ft = 'markdown', desc = '[P]Fold all headings level 3 or above' })

-- Keymap for folding markdown headings of level 4 or above
map('n', 'z;', function()
  -- "Update" saves only if the buffer has been modified since the last save
  vim.cmd 'silent update'
  -- map("n", "<leader>mf;", function()
  -- Unfold everything first or I had issues
  vim.cmd 'normal! zR'
  Util.markdown.fold_markdown_headings { 6, 5, 4 }
  vim.cmd 'normal! zz' -- center the cursor line on screen
end, { ft = 'markdown', desc = '[P]Fold all headings level 4 or above' })

-- Use <CR> to fold when in normal mode
-- To see help about folds use `:help fold`
map('n', '<CR>', function()
  -- Get the current line number
  local line = vim.fn.line '.'
  -- Get the fold level of the current line
  local foldlevel = vim.fn.foldlevel(line)
  if foldlevel == 0 then
    vim.notify('No fold found', vim.log.levels.INFO)
  else
    vim.cmd 'normal! za'
    vim.cmd 'normal! zz' -- center the cursor line on screen
  end
end, { desc = '[P]Toggle fold' })

-- Keymap for unfolding markdown headings of level 2 or above
-- Changed all the markdown folding and unfolding keymaps from <leader>mfj to
-- zj, zk, zl, z; and zu respectively lamw25wmal
map('n', 'zu', function()
  vim.cmd 'silent update'
  vim.cmd 'normal! zR'
  vim.cmd 'normal! zz'
end, { ft = 'markdown', desc = '[P]Unfold all headings level 2 or above' })

-- Keymap for  Generating/Updating TOC (markdown-toc)
map(
  'n',
  '<leader>mt',
  function() Util.markdown.update_markdown_toc('## Contents', '### Table of contents') end,
  { ft = 'markdown', desc = '[P]Insert/update Markdown TOC' }
)

-- Toggle bullet point at the beginning of the current line in normal mode
-- If in a multiline paragraph, make sure the cursor is on the line at the top
-- "d" is for "dash" lamw25wmal
map('n', '<leader>md', function() Util.markdown.toggle_bullet() end, { ft = 'markdown', desc = '[P]Toggle bullet point (dash)' })

-- In visual mode, check if the selected text is already striked through and show a message if it is
-- If not, surround it
map('v', '<leader>mx', function() Util.markdown.toggle_strikethrough() end, { ft = 'markdown', desc = '[P]Strike through current selection' })

-- In visual mode, check if the selected text is already bold and show a message if it is
-- If not, surround it with double asterisks for bold
map('v', '<leader>mb', function() Util.markdown.toggle_bold() end, { ft = 'markdown', desc = '[P]BOLD current selection' })

-- -- Multiline unbold attempt
-- -- In normal mode, bold the current word under the cursor
-- -- If already bold, it will unbold the word under the cursor
-- -- If you're in a multiline bold, it will unbold it only if you're on the
-- -- first line
map('n', '<leader>mb', function() Util.markdown.multiline_toggle_bold() end, { ft = 'markdown', desc = '[P]BOLD toggle bold markers' })

-- Show spelling suggestions / spell suggestions
-- NOTE: I changed this to accept the first spelling suggestion
map('n', '<leader>mss', function()
  -- Simulate pressing "z=" with "m" option using feedkeys
  -- vim.api.nvim_replace_termcodes ensures "z=" is correctly interpreted
  -- 'm' is the {mode}, which in this case is 'Remap keys'. This is default.
  -- If {mode} is absent, keys are remapped.
  --
  -- I tried this keymap as usually with
  vim.cmd 'normal! 1z='
  -- But didn't work, only with nvim_feedkeys
  -- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("z=", true, false, true), "m", true)
end, { ft = 'markdown', desc = '[P]Spelling suggestions' })

-- markdown good, accept spell suggestion
-- Add word under the cursor as a good word
map('n', '<leader>msg', function()
  vim.cmd 'normal! zg'
  -- I do a write so that harper is updated
  vim.cmd 'silent write'
end, { desc = '[P]Spelling add word to spellfile' })

-- Undo zw, remove the word from the entry in 'spellfile'.
map('n', '<leader>msu', function() vim.cmd 'normal! zug' end, { desc = '[P]Spelling undo, remove word from list' })

-- Repeat the replacement done by |z=| for all matches with the replaced word
-- in the current window.
map('n', '<leader>msr', function()
  -- vim.cmd(":spellr")
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(':spellr\n', true, false, true), 'm', true)
end, { desc = '[P]Spelling repeat' })

-- Keymap to switch to the daily note or create it if it does not exist
map('n', '<leader>fd', function()
  local current_line = vim.api.nvim_get_current_line()
  local date_line = current_line:match '%[%[%d+%-%d+%-%d+%-%w+%]%]' or ('[[' .. os.date '%Y-%m-%d-%A' .. ']]')
  Util.markdown.switch_to_daily_note(date_line)
end, { desc = '[P]Go to or create daily note' })

-- These create the the markdown heading
-- H1
map('n', '<leader>jj', function()
  local date_line = Util.markdown.insert_heading_and_date(1)
  -- If you just want to add the heading, comment the line below
  Util.markdown.create_daily_note(date_line)
end, { desc = '[P]H1 heading and date' })

-- H2
map('n', '<leader>kk', function()
  local date_line = Util.markdown.insert_heading_and_date(2)
  -- if you just want to add the heading, comment the line below
  Util.markdown.create_daily_note(date_line)
end, { desc = '[p]h2 heading and date' })

-- h3
map('n', '<leader>ll', function()
  local date_line = Util.markdown.insert_heading_and_date(3)
  -- if you just want to add the heading, comment the line below
  Util.markdown.create_daily_note(date_line)
end, { desc = '[p]h3 heading and date' })

-- h4
map('n', '<leader>;;', function()
  local date_line = Util.markdown.insert_heading_and_date(4)
  -- if you just want to add the heading, comment the line below
  Util.markdown.create_daily_note(date_line)
end, { desc = '[p]h4 heading and date' })

-- h5
map('n', '<leader>uu', function()
  local date_line = Util.markdown.insert_heading_and_date(5)
  -- if you just want to add the heading, comment the line below
  Util.markdown.create_daily_note(date_line)
end, { desc = '[p]h5 heading and date' })

-- h6
map('n', '<leader>ii', function()
  local date_line = Util.markdown.insert_heading_and_date(6)
  -- if you just want to add the heading, comment the line below
  Util.markdown.create_daily_note(date_line)
end, { desc = '[p]h6 heading and date' })

-- create or find a daily note
map('n', '<leader>fC', function()
  -- use the current line for date extraction
  local current_line = vim.api.nvim_get_current_line()
  Util.markdown.create_daily_note(current_line)
end, { desc = '[p]create daily note' })

-- create a daily note for the next day based on the current filename lamw26wmal
map('n', '<leader>ma', function() Util.markdown.create_next_n_days(1) end, { desc = "[p]create next day's daily note from current file" })

-- create the next 7 daily notes (one week) lamw26wmal
map('n', '<leader>mw', function() Util.markdown.create_next_n_days(7) end, { desc = "[p]create next week's daily notes from current file" })

-- create the next n daily notes (prompt) lamw26wmal
map('n', '<leader>md', function()
  -- ask for number of days starting from tomorrow
  vim.ui.input({ prompt = 'how many days to create (starting tomorrow): ', default = '7' }, function(answer)
    -- validate empty input
    if not answer or answer == '' then
      vim.api.nvim_echo({ { 'creation cancelled', 'warningmsg' } }, false, {})
      return
    end
    -- convert to number
    local n = tonumber(answer)
    -- validate number
    if not n then
      vim.api.nvim_echo({ { 'please enter a valid number', 'errormsg' } }, false, {})
      return
    end
    -- ensure integer > 0
    n = math.floor(n)
    if n <= 0 then
      vim.api.nvim_echo({ { 'enter a number greater than zero', 'errormsg' } }, false, {})
      return
    end
    Util.markdown.create_next_n_days(n)
  end)
end, { desc = '[p]create n next daily notes from current file' })

-- Increase markdown headings for text selected in visual mode
map('v', '<leader>mhI', function() Util.markdown.increment_current_heading() end, { ft = 'markdown', desc = 'Increase headings in visual selection' })

-- Decrease markdown headings for text selected in visual mode
map('v', '<leader>mhD', function() Util.markdown.decrement_current_heading() end, { ft = 'markdown', desc = 'Decrease headings in visual selection' })

-- Convert current markdown buffer to a .docx using pandoc
-- Assumes pandoc is installed and available in PATH (brew install pandoc)
map('n', '<leader>mcw', function()
  -- Save first so pandoc exports the latest content
  vim.cmd 'write'
  local md = vim.fn.expand '%:p'
  if md == '' then
    print 'No file name'
    return
  end
  local docx = vim.fn.expand '%:p:r' .. '.docx'
  local cmd = { 'pandoc', md, '-o', docx }
  vim.fn.jobstart(cmd, {
    on_exit = function(_, code)
      if code == 0 then
        print('Wrote ' .. docx)
      else
        print('pandoc failed (exit ' .. code .. ')')
      end
    end,
  })
end, { ft = 'markdown', desc = '[P]Markdown convert to word' })

-- ###########################################################################################
-- #                                    Markdown (END)
-- ###########################################################################################
