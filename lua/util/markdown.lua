local M = {}

function M.rename_image()
  local function get_image_path()
    -- Get the current line
    local line = vim.api.nvim_get_current_line()
    -- Pattern to match image path in Markdown
    local image_pattern = '%[.-%]%((.-)%)'
    -- Extract relative image path
    local _, _, image_path = string.find(line, image_pattern)
    return image_path
  end
  -- Get the image path
  local image_path = get_image_path()
  if not image_path then
    vim.api.nvim_echo({ { 'No image found under the cursor', 'WarningMsg' } }, false, {})
    return
  end
  -- Check if it's a URL
  if string.sub(image_path, 1, 4) == 'http' then
    vim.api.nvim_echo({ { 'URL images cannot be renamed.', 'WarningMsg' } }, false, {})
    return
  end
  -- Get absolute paths
  local current_file_path = vim.fn.expand '%:p:h'
  local absolute_image_path = current_file_path .. '/' .. image_path
  -- Check if file exists
  if vim.fn.filereadable(absolute_image_path) == 0 then
    vim.api.nvim_echo({ { 'Image file does not exist:\n', 'ErrorMsg' }, { absolute_image_path, 'ErrorMsg' } }, false, {})
    return
  end
  -- Get directory and extension of current image
  local dir = vim.fn.fnamemodify(absolute_image_path, ':h')
  local ext = vim.fn.fnamemodify(absolute_image_path, ':e')
  local current_name = vim.fn.fnamemodify(absolute_image_path, ':t:r')
  -- Prompt for new name
  vim.ui.input({ prompt = 'Enter new name (without extension): ', default = current_name }, function(new_name)
    if not new_name or new_name == '' then
      vim.api.nvim_echo({ { 'Rename cancelled', 'WarningMsg' } }, false, {})
      return
    end
    -- Construct new path
    local new_absolute_path = dir .. '/' .. new_name .. '.' .. ext
    -- Check if new filename already exists
    if vim.fn.filereadable(new_absolute_path) == 1 then
      vim.api.nvim_echo({ { 'File already exists: ' .. new_absolute_path, 'ErrorMsg' } }, false, {})
      return
    end
    -- Rename the file
    local success, err = os.rename(absolute_image_path, new_absolute_path)
    if success then
      -- Get the old and new filenames (without path)
      local old_filename = vim.fn.fnamemodify(absolute_image_path, ':t')
      local new_filename = vim.fn.fnamemodify(new_absolute_path, ':t')
      -- -- Debug prints
      -- print("Old filename:", old_filename)
      -- print("New filename:", new_filename)
      -- Get buffer content
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      -- print("Number of lines in buffer:", #lines)
      -- Replace the text in each line that contains the old filename
      for i = 0, #lines - 1 do
        local line = lines[i + 1]
        -- First find the image markdown pattern with explicit end
        local img_start, img_end = line:find '!%[.-%]%(.-%)'
        if img_start and img_end then
          -- Get just the exact markdown part without any extras
          local markdown_part = line:match '!%[.-%]%(.-%)'
          -- Replace old filename with new filename
          local escaped_old = old_filename:gsub('[%-%.%+%[%]%(%)%$%^%%%?%*]', '%%%1')
          local escaped_new = new_filename:gsub('[%%]', '%%%%')
          -- Replace in the exact markdown part
          local new_markdown = markdown_part:gsub(escaped_old, escaped_new)
          -- Replace that exact portion in the line
          vim.api.nvim_buf_set_text(
            0,
            i,
            img_start - 1,
            i,
            img_start + #markdown_part - 1, -- Use exact length of markdown part
            { new_markdown }
          )
        end
      end
      -- "Update" saves only if the buffer has been modified since the last save
      vim.cmd 'update'
      vim.api.nvim_echo({
        { 'Image renamed successfully', 'Normal' },
      }, false, {})
    else
      vim.api.nvim_echo({
        { 'Failed to rename image:\n', 'ErrorMsg' },
        { tostring(err), 'ErrorMsg' },
      }, false, {})
    end
  end)
end

-- Function to fold all headings of a specific level
function M.fold_headings_of_level(level)
  -- Move to the top of the file without adding to jumplist
  vim.cmd 'keepjumps normal! gg'
  -- Get the total number of lines
  local total_lines = vim.fn.line '$'
  for line = 1, total_lines do
    -- Get the content of the current line
    local line_content = vim.fn.getline(line)
    if vim.bo.filetype == 'typst' then
      if line_content:match('^' .. string.rep('=', level) .. '%s') then
        -- Move the cursor to the current line without adding to jumplist
        vim.cmd(string.format('keepjumps call cursor(%d, 1)', line))
        -- Check if the current line has a fold level > 0
        local current_foldlevel = vim.fn.foldlevel(line)
        if current_foldlevel > 0 then
          -- Fold the heading if it matches the level
          if vim.fn.foldclosed(line) == -1 then vim.cmd 'normal! za' end
          -- else
          --   vim.notify("No fold at line " .. line, vim.log.levels.WARN)
        end
      end
    else
      -- "^" -> Ensures the match is at the start of the line
      -- string.rep("#", level) -> Creates a string with 'level' number of "#" characters
      -- "%s" -> Matches any whitespace character after the "#" characters
      -- So this will match `## `, `### `, `#### ` for example, which are markdown headings
      if line_content:match('^' .. string.rep('#', level) .. '%s') then
        -- Move the cursor to the current line without adding to jumplist
        vim.cmd(string.format('keepjumps call cursor(%d, 1)', line))
        -- Check if the current line has a fold level > 0
        local current_foldlevel = vim.fn.foldlevel(line)
        if current_foldlevel > 0 then
          -- Fold the heading if it matches the level
          if vim.fn.foldclosed(line) == -1 then vim.cmd 'normal! za' end
          -- else
          --   vim.notify("No fold at line " .. line, vim.log.levels.WARN)
        end
      end
    end
  end
end

function M.fold_markdown_headings(levels)
  -- I save the view to know where to jump back after folding
  local saved_view = vim.fn.winsaveview()
  for _, level in ipairs(levels) do
    M.fold_headings_of_level(level)
  end
  vim.cmd 'nohlsearch'
  -- Restore the view to jump to where I was
  vim.fn.winrestview(saved_view)
end

-- Generate/update a Markdown TOC
-- To generate the TOC I use the markdown-toc plugin
-- https://github.com/jonschlinkert/markdown-toc
-- And the markdown-toc plugin installed as a LazyExtra
-- Function to update the Markdown TOC with customizable headings
function M.update_markdown_toc(heading2, heading3)
  local path = vim.fn.expand '%' -- Expands the current file name to a full path
  local bufnr = 0 -- The current buffer number, 0 references the current active buffer
  -- Save the current view
  -- If I don't do this, my folds are lost when I run this keymap
  vim.cmd 'mkview'
  -- Retrieves all lines from the current buffer
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local toc_exists = false -- Flag to check if TOC marker exists
  local frontmatter_end = 0 -- To store the end line number of frontmatter
  -- Check for frontmatter and TOC marker
  for i, line in ipairs(lines) do
    if i == 1 and line:match '^---$' then
      -- Frontmatter start detected, now find the end
      for j = i + 1, #lines do
        if lines[j]:match '^---$' then
          frontmatter_end = j
          break
        end
      end
    end
    -- Checks for the TOC marker
    if line:match '^%s*<!%-%-%s*toc%s*%-%->%s*$' then
      toc_exists = true
      break
    end
  end
  -- Inserts H2 and H3 headings and <!-- toc --> at the appropriate position
  if not toc_exists then
    local insertion_line = 1 -- Default insertion point after first line
    if frontmatter_end > 0 then
      -- Find H1 after frontmatter
      for i = frontmatter_end + 1, #lines do
        if lines[i]:match '^#%s+' then
          insertion_line = i + 1
          break
        end
      end
    else
      -- Find H1 from the beginning
      for i, line in ipairs(lines) do
        if line:match '^#%s+' then
          insertion_line = i + 1
          break
        end
      end
    end
    -- Insert the specified headings and <!-- toc --> without blank lines
    -- Insert the TOC inside a H2 and H3 heading right below the main H1 at the top lamw25wmal
    vim.api.nvim_buf_set_lines(bufnr, insertion_line, insertion_line, false, { heading2, heading3, '<!-- toc -->' })
  end
  -- Silently save the file, in case TOC is being created for the first time
  vim.cmd 'silent write'
  -- Silently run markdown-toc to update the TOC without displaying command output
  -- vim.fn.system("markdown-toc -i " .. path)
  -- I want my bulletpoints to be created only as "-" so passing that option as
  -- an argument according to the docs
  -- https://github.com/jonschlinkert/markdown-toc?tab=readme-ov-file#optionsbullets
  vim.fn.system('markdown-toc --bullets "-" -i ' .. path)
  vim.cmd 'edit!' -- Reloads the file to reflect the changes made by markdown-toc
  vim.cmd 'silent write' -- Silently save the file
  vim.notify('TOC updated and file saved', vim.log.levels.INFO)
  -- -- In case a cleanup is needed, leaving this old code here as a reference
  -- -- I used this code before I implemented the frontmatter check
  -- -- Moves the cursor to the top of the file
  -- vim.api.nvim_win_set_cursor(bufnr, { 1, 0 })
  -- -- Deletes leading blank lines from the top of the file
  -- while true do
  --   -- Retrieves the first line of the buffer
  --   local line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
  --   -- Checks if the line is empty
  --   if line == "" then
  --     -- Deletes the line if it's empty
  --     vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, {})
  --   else
  --     -- Breaks the loop if the line is not empty, indicating content or TOC marker
  --     break
  --   end
  -- end
  -- Restore the saved view (including folds)
  vim.cmd 'loadview'
end

function M.toggle_bullet()
  -- Get the current cursor position
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local current_buffer = vim.api.nvim_get_current_buf()
  local start_row = cursor_pos[1] - 1
  local col = cursor_pos[2]
  -- Get the current line
  local line = vim.api.nvim_buf_get_lines(current_buffer, start_row, start_row + 1, false)[1]
  -- Check if the line already starts with a bullet point
  if line:match '^%s*%-' then
    -- Remove the bullet point from the start of the line
    line = line:gsub('^%s*%-', '')
    vim.api.nvim_buf_set_lines(current_buffer, start_row, start_row + 1, false, { line })
    return
  end
  -- Search for newline to the left of the cursor position
  local left_text = line:sub(1, col)
  local bullet_start = left_text:reverse():find '\n'
  if bullet_start then bullet_start = col - bullet_start end
  -- Search for newline to the right of the cursor position and in following lines
  local right_text = line:sub(col + 1)
  local bullet_end = right_text:find '\n'
  local end_row = start_row
  while not bullet_end and end_row < vim.api.nvim_buf_line_count(current_buffer) - 1 do
    end_row = end_row + 1
    local next_line = vim.api.nvim_buf_get_lines(current_buffer, end_row, end_row + 1, false)[1]
    if next_line == '' then break end
    right_text = right_text .. '\n' .. next_line
    bullet_end = right_text:find '\n'
  end
  if bullet_end then bullet_end = col + bullet_end end
  -- Extract lines
  local text_lines = vim.api.nvim_buf_get_lines(current_buffer, start_row, end_row + 1, false)
  local text = table.concat(text_lines, '\n')
  -- Add bullet point at the start of the text
  local new_text = '- ' .. text
  local new_lines = vim.split(new_text, '\n')
  -- Set new lines in buffer
  vim.api.nvim_buf_set_lines(current_buffer, start_row, end_row + 1, false, new_lines)
end

function M.toggle_bold()
  local start_row, start_col = unpack(vim.fn.getpos "'<", 2, 3)
  local end_row, end_col = unpack(vim.fn.getpos "'>", 2, 3)
  -- Get the selected lines
  local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
  local selected_text = table.concat(lines, '\n'):sub(start_col, #lines == 1 and end_col or -1)
  if selected_text:match '^%*%*.*%*%*$' then
    vim.notify('Text already bold', vim.log.levels.INFO)
  else
    vim.cmd 'normal 2gsa*'
  end
end

-- Function
function M.toggle_task()
  local current_buffer = vim.api.nvim_get_current_buf()

  -- Determine row range based on mode
  local start_row, end_row
  local mode = vim.fn.mode()

  if mode == 'v' or mode == 'V' or mode == '\22' then
    -- Visual mode: use visual selection marks
    start_row = vim.fn.getpos('v')[2] - 1
    end_row = vim.fn.getpos('.')[2] - 1
    -- Normalise in case cursor is above anchor
    if start_row > end_row then
      start_row, end_row = end_row, start_row
    end
  else
    -- Normal mode: only the current line
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    start_row = cursor_pos[1] - 1
    end_row = start_row
  end

  -- Toggle each line independently
  for row = start_row, end_row do
    local line = vim.api.nvim_buf_get_lines(current_buffer, row, row + 1, false)[1]
    -- Skip empty lines
    if line:match '^%s*$' then goto continue end
    local new_line

    if line:match '^%s*%-%s%[x%]' then
      -- [x] → [ ]
      new_line = line:gsub('^(%s*%-%s)%[x%]', '%1[ ]')
    elseif line:match '^%s*%-%s%[%s%]' then
      -- [ ] → plain bullet
      new_line = line:gsub('^(%s*%-%s)%[%s%]%s?', '%1')
    elseif line:match '^%s*%-%s' then
      -- plain bullet → [ ]
      new_line = line:gsub('^(%s*%-%s)', '%1[ ] ')
    else
      -- bare text → - [ ]
      new_line = '- [ ] ' .. line
    end
    vim.api.nvim_buf_set_lines(current_buffer, row, row + 1, false, { new_line })
    ::continue::
  end

  -- Exit visual mode after applying
  if mode == 'v' or mode == 'V' or mode == '\22' then vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false) end
end

function M.multiline_toggle_bold()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local current_buffer = vim.api.nvim_get_current_buf()
  local start_row = cursor_pos[1] - 1
  local col = cursor_pos[2]
  -- Get the current line
  local line = vim.api.nvim_buf_get_lines(current_buffer, start_row, start_row + 1, false)[1]
  -- Check if the cursor is on an asterisk
  if line:sub(col + 1, col + 1):match '%*' then
    vim.notify('Cursor is on an asterisk, run inside the bold text', vim.log.levels.WARN)
    return
  end
  -- Search for '**' to the left of the cursor position
  local left_text = line:sub(1, col)
  local bold_start = left_text:reverse():find '%*%*'
  if bold_start then bold_start = col - bold_start end
  -- Search for '**' to the right of the cursor position and in following lines
  local right_text = line:sub(col + 1)
  local bold_end = right_text:find '%*%*'
  local end_row = start_row
  while not bold_end and end_row < vim.api.nvim_buf_line_count(current_buffer) - 1 do
    end_row = end_row + 1
    local next_line = vim.api.nvim_buf_get_lines(current_buffer, end_row, end_row + 1, false)[1]
    if next_line == '' then break end
    right_text = right_text .. '\n' .. next_line
    bold_end = right_text:find '%*%*'
  end
  if bold_end then bold_end = col + bold_end end
  -- Remove '**' markers if found, otherwise bold the word
  if bold_start and bold_end then
    -- Extract lines
    local text_lines = vim.api.nvim_buf_get_lines(current_buffer, start_row, end_row + 1, false)
    local text = table.concat(text_lines, '\n')
    -- Calculate positions to correctly remove '**'
    -- vim.notify("bold_start: " .. bold_start .. ", bold_end: " .. bold_end)
    local new_text = text:sub(1, bold_start - 1) .. text:sub(bold_start + 2, bold_end - 1) .. text:sub(bold_end + 2)
    local new_lines = vim.split(new_text, '\n')
    -- Set new lines in buffer
    vim.api.nvim_buf_set_lines(current_buffer, start_row, end_row + 1, false, new_lines)
    -- vim.notify("Unbolded text", vim.log.levels.INFO)
  else
    -- Bold the word at the cursor position if no bold markers are found
    local before = line:sub(1, col)
    local after = line:sub(col + 1)
    local inside_surround = before:match '%*%*[^%*]*$' and after:match '^[^%*]*%*%*'
    if inside_surround then
      vim.cmd 'normal gsd*.'
    else
      vim.cmd 'normal viw'
      vim.cmd 'normal 2gsa*'
    end
    vim.notify('Bolded current word', vim.log.levels.INFO)
  end
end

function M.toggle_strikethrough()
  -- Get the selected text range
  local start_row, start_col = unpack(vim.fn.getpos "'<", 2, 3)
  local end_row, end_col = unpack(vim.fn.getpos "'>", 2, 3)
  -- Get the selected lines
  local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
  local selected_text = table.concat(lines, '\n'):sub(start_col, #lines == 1 and end_col or -1)
  if selected_text:match '^%~%~.*%~%~$' then
    vim.notify('Text already has strikethrough', vim.log.levels.INFO)
  else
    vim.cmd 'normal 2gsa~'
  end
end

-- These create the a markdown heading based on the level specified, and also
-- dynamically add the date below in the [[2024-03-01-Friday]] format
function M.insert_heading_and_date(level)
  local date = os.date '%Y-%m-%d-%A'
  local heading = string.rep('#', level) .. ' ' -- Generate heading based on the level
  local dateLine = '[[' .. date .. ']]' -- Formatted date line
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0)) -- Get the current row number
  -- Insert both lines: heading and dateLine
  vim.api.nvim_buf_set_lines(0, row, row, false, { heading, dateLine })
  -- Move the cursor to the end of the heading
  vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
  -- Enter insert mode at the end of the current line
  vim.cmd 'startinsert!'
  return dateLine
  -- vim.api.nvim_win_set_cursor(0, { row, #heading })
end

-- parse date line and generate file path components for the daily note
function M.parse_date_line(date_line)
  local home = os.getenv 'HOME'
  local year, month, day, weekday = date_line:match '%[%[(%d+)%-(%d+)%-(%d+)%-(%w+)%]%]'
  if not (year and month and day and weekday) then
    print 'No valid date found in the line'
    return nil
  end
  local month_abbr = os.date('%b', os.time { year = year, month = month, day = day })
  local note_dir = string.format('%s/Documents/myobsidianvault/250-daily/%s/%s-%s', home, year, month, month_abbr)
  local note_name = string.format('%s-%s-%s-%s.md', year, month, day, weekday)
  return note_dir, note_name
end

-- get the full path of the daily note
function M.get_daily_note_path(date_line)
  local note_dir, note_name = M.parse_date_line(date_line)
  if not note_dir or not note_name then return nil end
  return note_dir .. '/' .. note_name
end

-- Updated create_daily_note function using helper functions
-- Create or find a daily note based on a date line format and open it in Neovim
-- This is used in obsidian markdown files that have the "Link to non-existent
-- document" warning
function M.create_daily_note(date_line)
  local full_path = M.get_daily_note_path(date_line)
  if not full_path then return end
  local note_dir = full_path:match '(.*/)' -- Extract directory path from full path
  -- Ensure the directory exists
  vim.fn.mkdir(note_dir, 'p')
  -- Check if the file exists and create it if it doesn't
  if vim.fn.filereadable(full_path) == 0 then
    local file = io.open(full_path, 'w')
    if file then
      file:write '# Contents\n\n<!-- toc -->\n\n- [Daily Note](#daily-note)\n\n<!-- tocstop -->\n\n## Daily Note\n'
      file:close()
      vim.cmd('edit ' .. vim.fn.fnameescape(full_path))
      vim.cmd 'bd!'
      vim.api.nvim_echo({
        { 'CREATED DAILY NOTE\n', 'WarningMsg' },
        { full_path, 'WarningMsg' },
      }, false, {})
    else
      print('Failed to create file: ' .. full_path)
    end
  else
    print('Daily note already exists: ' .. full_path)
  end
end

-- extract the y-m-d parts from the current filename
function M.current_file_date()
  local fname = vim.fn.expand '%:t'
  local y, m, d = fname:match '^(%d+)%-(%d+)%-(%d+)%-%w+%.md$'
  return y, m, d
end

-- create n consecutive daily notes, starting tomorrow
function M.create_next_n_days(n)
  local y, m, d = M.current_file_date()
  if not (y and m and d) then
    vim.api.nvim_echo({ { 'current file is not a valid daily note filename', 'errormsg' } }, false, {})
    return
  end
  local base_ts = os.time { year = y, month = m, day = d }
  for i = 1, n do
    local t = os.date('*t', base_ts + 86400 * i)
    local link = string.format('[[%04d-%02d-%02d-%s]]', t.year, t.month, t.day, os.date('%A', os.time { year = t.year, month = t.month, day = t.day }))
    M.create_daily_note(link)
  end
end

-- Function to switch to the daily note or create it if it does not exist
function M.switch_to_daily_note(date_line)
  local full_path = M.get_daily_note_path(date_line)
  if not full_path then return end
  M.create_daily_note(date_line)
  vim.cmd('edit ' .. vim.fn.fnameescape(full_path))
end

function M.increment_current_heading()
  -- Save cursor position
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  -- Get visual selection bounds and ensure correct order
  local start_line = vim.fn.line "'<"
  local end_line = vim.fn.line "'>"
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  local buf = vim.api.nvim_get_current_buf()
  -- Process each line in the selection
  for lnum = start_line, end_line do
    local line = vim.api.nvim_buf_get_lines(buf, lnum - 1, lnum, false)[1]
    if line and line:match '^##+%s' then -- Match headings level 2+
      local new_line = '#' .. line
      vim.api.nvim_buf_set_lines(buf, lnum - 1, lnum, false, { new_line })
    end
  end
  -- Restore cursor and clear highlights
  vim.api.nvim_win_set_cursor(0, cursor_pos)
  vim.cmd 'nohlsearch'
end

function M.decrement_current_heading()
  -- Save cursor position
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  -- Get visual selection bounds and ensure correct order
  local start_line = vim.fn.line "'<"
  local end_line = vim.fn.line "'>"
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  local buf = vim.api.nvim_get_current_buf()
  -- Process each line in the selection
  for lnum = start_line, end_line do
    local line = vim.api.nvim_buf_get_lines(buf, lnum - 1, lnum, false)[1]
    if line and line:match '^##+%s' then -- Match headings level 2+
      -- Split into hashes and content, then remove one #
      local hashes, content = line:match '^(#+)(%s.+)$'
      if hashes and #hashes >= 2 then
        local new_hashes = hashes:sub(1, #hashes - 1)
        local new_line = new_hashes .. content
        vim.api.nvim_buf_set_lines(buf, lnum - 1, lnum, false, { new_line })
      end
    end
  end
  -- Restore cursor and clear highlights
  vim.api.nvim_win_set_cursor(0, cursor_pos)
  vim.cmd 'nohlsearch'
end

-- Convert current markdown buffer to a .docx using pandoc
-- Assumes pandoc is installed and available in PATH (brew install pandoc)
vim.keymap.set('n', '<leader>mcw', function()
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
end, { desc = '[P]Markdown convert to word' })

-- NOTE: Configuration for image storage path
-- Change this to customize where images are stored relative to the assets directory
-- If below you use "img/imgs", it will store in "assets/img/imgs"
-- Added option to choose image format and resolution lamw26wmal
local IMAGE_STORAGE_PATH = 'img/imgs'

-- This function is used in 2 places in the paste images in assets dir section
-- finds the assets/img/imgs directory going one dir at a time and returns the full path
function M.find_assets_dir()
  local dir = vim.fn.expand '%:p:h'
  while dir ~= '/' do
    local full_path = dir .. '/assets/' .. IMAGE_STORAGE_PATH
    if vim.fn.isdirectory(full_path) == 1 then return full_path end
    dir = vim.fn.fnamemodify(dir, ':h')
  end
  return nil
end

-- Since I need to store these images in a different directory, I pass the options to img-clip
function M.handle_image_paste(img_dir)
  local function paste_image(dir_path, file_name, ext, cmd)
    return require('img-clip').paste_image {
      dir_path = dir_path,
      use_absolute_path = false,
      relative_to_current_file = false,
      file_name = file_name,
      extension = ext or 'avif',
      process_cmd = cmd or 'convert - -quality 75 avif:-',
    }
  end
  local temp_buf = vim.api.nvim_create_buf(false, true) -- Create an unlisted, scratch buffer
  vim.api.nvim_set_current_buf(temp_buf) -- Switch to the temporary buffer
  local temp_image_path = vim.fn.tempname() .. '.avif'
  local image_pasted = paste_image(vim.fn.fnamemodify(temp_image_path, ':h'), vim.fn.fnamemodify(temp_image_path, ':t:r'))
  vim.api.nvim_buf_delete(temp_buf, { force = true }) -- Delete the buffer
  vim.fn.delete(temp_image_path) -- Delete the temporary file
  vim.defer_fn(function()
    local options = image_pasted and { 'no', 'yes', 'format', 'search' } or { 'search' }
    local prompt = image_pasted and 'Is this a thumbnail image? ' or 'No image in clipboard. Select search to continue.'
    -- -- I was getting a character in the textbox, don't want to debug right now
    -- vim.cmd("stopinsert")
    vim.ui.select(options, { prompt = prompt }, function(is_thumbnail)
      if is_thumbnail == 'search' then
        local assets_dir = M.find_assets_dir()
        -- Get the parent directory of the current file
        local current_dir = vim.fn.expand '%:p:h'
        -- remove warning: Cannot assign `string|nil` to parameter `string`
        if not assets_dir then
          print 'Assets directory not found, cannot proceed with search.'
          return
        end
        -- Get the parent directory of assets_dir (removing /img/imgs)
        local base_assets_dir = vim.fn.fnamemodify(assets_dir, ':h:h:h')
        -- Count how many levels we need to go up
        local levels = 0
        local temp_dir = current_dir
        while temp_dir ~= base_assets_dir and temp_dir ~= '/' do
          levels = levels + 1
          temp_dir = vim.fn.fnamemodify(temp_dir, ':h')
        end
        -- Build the relative path
        local relative_path = levels == 0 and './assets/' .. IMAGE_STORAGE_PATH or string.rep('../', levels) .. 'assets/' .. IMAGE_STORAGE_PATH
        vim.api.nvim_put({ '![Image](' .. relative_path .. '){: width="500" }' }, 'c', true, true)
        -- Capital "O" to move to the line above
        vim.cmd 'normal! O'
        -- This "o" is to leave a blank line above
        vim.cmd 'normal! o'
        vim.api.nvim_put({ '<!-- prettier-ignore -->' }, 'c', true, true)
        vim.cmd 'normal! jo'
        vim.api.nvim_put({ '_textimage_', '' }, 'c', true, true)
        -- find image path and add a / at the end of it
        vim.cmd 'normal! kkf)i/'
        -- Move one to the right and enter insert mode
        vim.cmd 'normal! la'
        -- -- This puts me in insert mode where the cursor is
        -- vim.api.nvim_feedkeys("i", "n", true)
        require('auto-save').on()
        return
      end
      if not is_thumbnail then
        print 'Image pasting canceled.'
        require('auto-save').on()
        return
      end
      if is_thumbnail == 'format' then
        local extension_options = { 'avif', 'webp', 'png', 'jpg' }
        vim.ui.select(extension_options, {
          prompt = 'Select image format:',
          default = 'avif',
        }, function(selected_ext)
          if not selected_ext then return end
          -- Define proceed_with_paste with proper parameter names
          local function proceed_with_paste(process_command)
            local prefix = vim.fn.strftime '%y%m%d-'
            local function prompt_for_name()
              vim.ui.input({ prompt = 'Enter image name (no spaces). Added prefix: ' .. prefix }, function(input_name)
                if not input_name or input_name:match '%s' then
                  print 'Invalid image name or canceled. Image not pasted.'
                  require('auto-save').on()
                  return
                end
                local full_image_name = prefix .. input_name
                local file_path = img_dir .. '/' .. full_image_name .. '.' .. selected_ext
                if vim.fn.filereadable(file_path) == 1 then
                  print 'Image name already exists. Please enter a new name.'
                  prompt_for_name()
                else
                  if paste_image(img_dir, full_image_name, selected_ext, process_command) then
                    vim.api.nvim_put({ '{: width="500" }' }, 'c', true, true)
                    vim.cmd 'normal! O'
                    vim.cmd 'stopinsert'
                    vim.cmd 'normal! o'
                    vim.api.nvim_put({ '<!-- prettier-ignore -->' }, 'c', true, true)
                    vim.cmd 'normal! j$o'
                    vim.cmd 'stopinsert'
                    vim.api.nvim_put({ '__' }, 'c', true, true)
                    vim.cmd 'normal! h'
                    vim.cmd 'silent! update'
                    vim.cmd 'edit!'
                    require('auto-save').on()
                  else
                    print 'No image pasted. File not updated.'
                    require('auto-save').on()
                  end
                end
              end)
            end
            prompt_for_name()
          end
          -- Resolution prompt handling
          vim.ui.select({ 'Yes', 'No' }, {
            prompt = 'Change image resolution?',
            default = 'No',
          }, function(resize_choice)
            local process_cmd
            if resize_choice == 'Yes' then
              vim.ui.input({
                prompt = 'Enter max height (default 1080): ',
                default = '1080',
              }, function(height_input)
                local height = tonumber(height_input) or 1080
                process_cmd = string.format('convert - -resize x%d -quality 100 %s:-', height, selected_ext)
                proceed_with_paste(process_cmd)
              end)
            else
              process_cmd = 'convert - -quality 75 ' .. selected_ext .. ':-'
              proceed_with_paste(process_cmd)
            end
          end)
        end)
        return
      end
      local prefix = vim.fn.strftime '%y%m%d-' .. (is_thumbnail == 'yes' and 'thux-' or '')
      local function prompt_for_name()
        vim.ui.input({ prompt = 'Enter image name (no spaces). Added prefix: ' .. prefix }, function(input_name)
          if not input_name or input_name:match '%s' then
            print 'Invalid image name or canceled. Image not pasted.'
            return
          end
          local full_image_name = prefix .. input_name
          local file_path = img_dir .. '/' .. full_image_name .. '.avif'
          if vim.fn.filereadable(file_path) == 1 then
            print 'Image name already exists. Please enter a new name.'
            prompt_for_name()
          else
            if paste_image(img_dir, full_image_name) then
              vim.api.nvim_put({ '{: width="500" }' }, 'c', true, true)
              -- Create new line above and force normal mode
              vim.cmd 'normal! O'
              vim.cmd 'stopinsert' -- Explicitly exit insert mode
              -- Create blank line above and force normal mode
              vim.cmd 'normal! o'
              vim.cmd 'stopinsert'
              vim.api.nvim_put({ '<!-- prettier-ignore -->' }, 'c', true, true)
              -- Move down and create new line (without staying in insert mode)
              vim.cmd 'normal! j$o'
              vim.cmd 'stopinsert'
              vim.api.nvim_put({ '__' }, 'c', true, true)
              vim.cmd 'normal! h' -- Position cursor between underscores
              vim.cmd 'silent! update'
              vim.cmd 'edit!'
            else
              print 'No image pasted. File not updated.'
            end
          end
        end)
      end
      prompt_for_name()
    end)
  end, 100)
end

function M.process_image()
  local img_dir = M.find_assets_dir()
  if not img_dir then
    vim.ui.select({ 'yes', 'no' }, {
      prompt = IMAGE_STORAGE_PATH .. ' directory not found. Create it?',
      default = 'yes',
    }, function(choice)
      if choice == 'yes' then
        img_dir = vim.fn.getcwd() .. '/assets/' .. IMAGE_STORAGE_PATH
        vim.fn.mkdir(img_dir, 'p')
        -- Start the image paste process after creating directory
        vim.defer_fn(function() M.handle_image_paste(img_dir) end, 100)
      else
        print 'Operation cancelled - directory not created'
        return
      end
    end)
    return
  end
  M.handle_image_paste(img_dir)
end

function M.copy_all_hyperlinks()
  -- Get all lines in current buffer
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  -- Prepare a set for unique URLs and an ordered list to preserve first-seen order
  local seen = {}
  local urls = {}
  -- Lua pattern for https URLs
  local pat = 'https://%S+'
  -- Characters to trim from the end of a found URL (common closers/punctuation)
  local function rtrim_url(u)
    -- Remove trailing ), ], }, ., ,, ;, :, ?, !, ', ", >
    while u:match '[%)%]%}%.%,%;%:%?%!%\'%">%)]$' do
      u = u:sub(1, #u - 1)
    end
    -- Balance a trailing unmatched ')' from markdown links like (https://...))
    local open_paren = select(2, u:gsub('%(', ''))
    local close_paren = select(2, u:gsub('%)', ''))
    if close_paren > open_paren and u:sub(-1) == ')' then u = u:sub(1, #u - 1) end
    return u
  end
  -- Scan each line and collect matches
  for _, line in ipairs(lines) do
    for m in line:gmatch(pat) do
      local url = rtrim_url(m)
      if not seen[url] then
        seen[url] = true
        table.insert(urls, url)
      end
    end
  end
  -- If none found, inform and exit
  if #urls == 0 then
    print 'No https URLs found in buffer'
    return
  end
  -- Join and copy to system clipboard register +
  local blob = table.concat(urls, '\n')
  vim.fn.setreg('+', blob)
  -- Also put into unnamed register
  vim.fn.setreg('"', blob)
  -- Notify how many were copied
  print(('Copied %d URL(s) to clipboard'):format(#urls))
end

function M.task_toggle()
  local label_done = 'done:'
  local timestamp = os.date '%y%m%d-%H%M'
  local heading_completed = '## Completed Tasks'
  local heading_incomplete = '## Incomplete Tasks'

  vim.cmd 'mkview'
  local api = vim.api
  local buf = api.nvim_get_current_buf()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local start_line = cursor_pos[1] - 1
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local total_lines = #lines

  if start_line >= total_lines then
    vim.cmd 'loadview'
    return
  end

  ---------------------------------------------------------------------------
  -- (A) Walk up to the nearest bullet line
  ---------------------------------------------------------------------------
  while start_line > 0 do
    local t = lines[start_line + 1]
    if t == '' or t:match '^%s*%-' then break end
    start_line = start_line - 1
  end
  if lines[start_line + 1] == '' and start_line < (total_lines - 1) then start_line = start_line + 1 end

  ---------------------------------------------------------------------------
  -- (B) Validate task bullet
  ---------------------------------------------------------------------------
  if not lines[start_line + 1]:match '^%s*%- %[[x ]%]' then
    print 'Not a task bullet: no action taken.'
    vim.cmd 'loadview'
    return
  end

  ---------------------------------------------------------------------------
  -- 1. Identify chunk boundaries
  ---------------------------------------------------------------------------
  local chunk_start = start_line
  local chunk_end = start_line
  while chunk_end + 1 < total_lines do
    local nxt = lines[chunk_end + 2]
    if nxt == '' or nxt:match '^%s*%-' then break end
    chunk_end = chunk_end + 1
  end

  local chunk = {}
  for i = chunk_start, chunk_end do
    table.insert(chunk, lines[i + 1])
  end

  ---------------------------------------------------------------------------
  -- 2. Normalise legacy bracket-style labels
  ---------------------------------------------------------------------------
  for i, line in ipairs(chunk) do
    chunk[i] = line:gsub('%[done:([^%]]+)%]', '`' .. label_done .. '%1`')
    chunk[i] = chunk[i]:gsub('%[untoggled%]', '`untoggled`')
  end

  ---------------------------------------------------------------------------
  -- 3. Detect chunk state
  ---------------------------------------------------------------------------
  local has_done_index, has_untoggled_index
  for i, line in ipairs(chunk) do
    if line:match('`' .. label_done .. '.-`') then
      has_done_index = i
      break
    end
  end
  if not has_done_index then
    for i, line in ipairs(chunk) do
      if line:match '`untoggled`' then
        has_untoggled_index = i
        break
      end
    end
  end

  ---------------------------------------------------------------------------
  -- 4. Bullet / label helpers
  ---------------------------------------------------------------------------
  local function bulletToX(l) return l:gsub('^(%s*%- )%[%s*%]', '%1[x]') end
  local function bulletToBlank(l) return l:gsub('^(%s*%- )%[x%]', '%1[ ]') end

  local function insertLabel(line, label)
    local prefix = line:match '^(%s*%- %[[x ]%])'
    if not prefix then return line end
    return prefix .. ' ' .. label .. line:sub(#prefix + 1)
  end

  local function removeLabel(line) return line:gsub('^(%s*%- %[[x ]%])%s+`.-`', '%1') end

  ---------------------------------------------------------------------------
  -- 5. Replace every label in the whole chunk (line 1 handled separately)
  ---------------------------------------------------------------------------
  local function relabelChunk(from_pat, to_label)
    for i = 2, #chunk do
      chunk[i] = chunk[i]:gsub(from_pat, to_label)
    end
  end

  ---------------------------------------------------------------------------
  -- 6. Core move helper: remove chunk then insert under target heading.
  --    If target heading is absent, create it — anchored just above
  --    `anchor_heading` when provided, otherwise appended at end of buffer.
  ---------------------------------------------------------------------------
  local function move_chunk_to(ls, target_heading, anchor_heading)
    -- Remove chunk from its current position
    for i = chunk_end, chunk_start, -1 do
      table.remove(ls, i + 1)
    end

    -- Locate (or create) the target heading
    local hdg_idx
    for i, line in ipairs(ls) do
      if line == target_heading then
        hdg_idx = i
        break
      end
    end

    if not hdg_idx then
      -- Find the anchor to insert just above it
      local anchor_idx
      if anchor_heading then
        for i, line in ipairs(ls) do
          if line == anchor_heading then
            anchor_idx = i
            break
          end
        end
      end

      if anchor_idx then
        -- Guarantee a blank line above the new heading
        if anchor_idx > 1 and ls[anchor_idx - 1] ~= '' then
          table.insert(ls, anchor_idx, '')
          anchor_idx = anchor_idx + 1
        end
        table.insert(ls, anchor_idx, target_heading)
        hdg_idx = anchor_idx
      else
        -- Nothing to anchor to — append at end
        if ls[#ls] ~= '' then table.insert(ls, '') end
        table.insert(ls, target_heading)
        hdg_idx = #ls
      end
    end

    -- Insert chunk items right after the heading (reverse to preserve order)
    for j = #chunk, 1, -1 do
      table.insert(ls, hdg_idx + 1, chunk[j])
    end

    -- Remove any stray blank line immediately after the inserted block
    local after = hdg_idx + #chunk + 1
    if ls[after] == '' then table.remove(ls, after) end

    return ls
  end

  ---------------------------------------------------------------------------
  -- 7. Main toggle logic
  ---------------------------------------------------------------------------

  if has_done_index then
    -------------------------------------------------------------------------
    -- [x] `done: …`  →  [ ] `untoggled`  →  move to ## Incomplete Tasks
    -- FIX: was updateBufferWithChunk (in-place); now removes and reinserts
    -------------------------------------------------------------------------
    chunk[1] = bulletToBlank(chunk[1])
    chunk[1] = removeLabel(chunk[1])
    chunk[1] = insertLabel(chunk[1], '`untoggled`')
    relabelChunk('`' .. label_done .. '.-`', '`untoggled`')

    lines = move_chunk_to(lines, heading_incomplete, heading_completed)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.notify('Untoggled', vim.log.levels.INFO)
  elseif has_untoggled_index then
    -------------------------------------------------------------------------
    -- [ ] `untoggled`  →  [x] `done: …`  →  move to ## Completed Tasks
    -- FIX: was updateBufferWithChunk (in-place); now removes and reinserts
    -------------------------------------------------------------------------
    local done_label = '`' .. label_done .. ' ' .. timestamp .. '`'
    chunk[1] = bulletToX(chunk[1])
    chunk[1] = removeLabel(chunk[1])
    chunk[1] = insertLabel(chunk[1], done_label)
    relabelChunk('`untoggled`', done_label)

    lines = move_chunk_to(lines, heading_completed, nil)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.notify('Completed', vim.log.levels.INFO)
  else
    -------------------------------------------------------------------------
    -- [ ] (no label)  →  [x] `done: …`  →  move to ## Completed Tasks
    -------------------------------------------------------------------------
    local win = api.nvim_get_current_win()
    local view = api.nvim_win_call(win, function() return vim.fn.winsaveview() end)
    local done_label = '`' .. label_done .. ' ' .. timestamp .. '`'

    chunk[1] = bulletToX(chunk[1])
    chunk[1] = insertLabel(chunk[1], done_label)

    lines = move_chunk_to(lines, heading_completed, nil)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.notify('Completed', vim.log.levels.INFO)

    api.nvim_win_call(win, function() vim.fn.winrestview(view) end)
  end

  vim.cmd 'silent update'
  vim.cmd 'loadview'
end

function M.toggle_todo()
  -- Get the current line
  local current_line = vim.fn.getline '.'
  -- Get the current line number
  local line_number = vim.fn.line '.'
  if string.find(current_line, 'TODO:') then
    -- Replace the first occurrence of ":" with ";"
    local new_line = current_line:gsub('TODO:', 'TODO;')
    -- Set the modified line
    vim.fn.setline(line_number, new_line)
  elseif string.find(current_line, 'TODO;') then
    -- Replace the first occurrence of ";" with ":"
    local new_line = current_line:gsub('TODO;', 'TODO:')
    -- Set the modified line
    vim.fn.setline(line_number, new_line)
  else
    vim.cmd "echo 'todo item not detected'"
  end
end
function M.jump_to_toc()
  -- Save the current cursor position
  _G.saved_positions['toc_return'] = vim.api.nvim_win_get_cursor(0)
  -- Perform a silent search for the <!-- toc --> marker and move the cursor two lines below it
  vim.cmd 'silent! /<!-- toc -->\\n\\n\\zs.*'
  -- Clear the search highlight without showing the "search hit BOTTOM, continuing at TOP" message
  vim.cmd 'nohlsearch'
  -- Retrieve the current cursor position (after moving to the TOC)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local row = cursor_pos[1]
  -- local col = cursor_pos[2]
  -- Move the cursor to column 15 (starts counting at 0)
  -- I like just going down on the TOC and press gd to go to a section
  vim.api.nvim_win_set_cursor(0, { row, 14 })
end

function M.jump_to_prev_cursor()
  local pos = _G.saved_positions['toc_return']
  if pos then vim.api.nvim_win_set_cursor(0, pos) end
end

function M.set_markdown_folding()
  vim.opt_local.foldmethod = 'expr'
  vim.opt_local.foldexpr = 'v:lua.markdown_foldexpr()'
  vim.opt_local.foldlevel = 99

  -- Detect frontmatter closing line
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local found_first = false
  local frontmatter_end = nil
  for i, line in ipairs(lines) do
    if line == '---' then
      if not found_first then
        found_first = true
      else
        frontmatter_end = i
        break
      end
    end
  end
  vim.b.frontmatter_end = frontmatter_end
end
return M
