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

return M
