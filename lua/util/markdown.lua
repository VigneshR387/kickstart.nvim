local M = {}

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
    vim.cmd 'normal 2sa*'
  end
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
      vim.cmd 'normal sd*sd*'
    else
      vim.cmd 'normal viw'
      vim.cmd 'normal 2sa*'
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
    vim.cmd 'normal 2sa~'
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
  local note_dir = string.format('%s/github/obsidian_main/250-daily/%s/%s-%s', home, year, month, month_abbr)
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
      file:write '# Contents\n\n<!-- toc -->\n\n- [Daily note](#daily-note)\n\n<!-- tocstop -->\n\n## Daily note\n'
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

return M
