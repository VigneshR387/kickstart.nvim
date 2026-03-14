local M = {}

-- Function to delete the current file with confirmation
function M.delete_current_file()
  local current_file = vim.fn.expand '%:p'
  if current_file and current_file ~= '' then
    -- Check if trash utility is installed
    if vim.fn.executable 'trash' == 0 then
      vim.api.nvim_echo({
        { '- Trash utility not installed. Make sure to install it first\n', 'ErrorMsg' },
      }, false, {})
      return
    end
    -- Prompt for confirmation before deleting the file
    vim.ui.input({
      prompt = "Type 'del' to delete the file '" .. current_file .. "': ",
    }, function(input)
      if input == 'del' then
        -- Delete the file using trash app
        local success, _ = pcall(function() vim.fn.system { 'trash', vim.fn.fnameescape(current_file) } end)
        if success then
          vim.api.nvim_echo({
            { 'File deleted from disk:\n', 'Normal' },
            { current_file, 'Normal' },
          }, false, {})
          -- Close the buffer after deleting the file
          vim.cmd 'bd!'
        else
          vim.api.nvim_echo({
            { 'Failed to delete file:\n', 'ErrorMsg' },
            { current_file, 'ErrorMsg' },
          }, false, {})
        end
      else
        vim.api.nvim_echo({
          { 'File deletion canceled.', 'Normal' },
        }, false, {})
      end
    end)
  else
    vim.api.nvim_echo({
      { 'No file to delete', 'WarningMsg' },
    }, false, {})
  end
end

function M.file_detail()
  local filePath = vim.fn.expand '%:~'

  -- Check if header already exists
  local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ''
  if first_line:match 'Filename:' then
    vim.notify('Header already exists', vim.log.levels.INFO)
    return
  end

  local lines = { 'Filename: ' .. filePath, filePath }

  -- Check if it's a lazy.nvim plugin spec by scanning the buffer
  local buf_lines = vim.api.nvim_buf_get_lines(0, 0, 50, false)
  for _, line in ipairs(buf_lines) do
    local owner, repo = line:match '[\'"]([%w_%-%.]+)/([%w_%-%.]+)[\'"]'
    if owner and repo then
      table.insert(lines, 'https://github.com/' .. owner .. '/' .. repo)
      break
    end
  end

  -- Insert at the top of the file
  vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)

  -- Select and comment the inserted lines
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  vim.cmd('normal! V' .. (#lines - 1) .. 'j')
  vim.cmd 'normal gcc'
end

return M
