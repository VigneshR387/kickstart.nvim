local M = {}
function M.task_toggle()
  local label_done = 'done:'
  local timestamp = os.date '%y%m%d-%H%M'
  -- Neorg uses single `*` for headings
  local heading_completed = '** Completed Tasks'
  local heading_incomplete = '** Incomplete Tasks'

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
  -- (B) Validate task bullet: neorg uses - ( ) and - (x)
  ---------------------------------------------------------------------------
  if not lines[start_line + 1]:match '^%s*%- %([x ]%)' then
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
  -- 4. Bullet / label helpers (neorg parens instead of brackets)
  ---------------------------------------------------------------------------
  local function bulletToX(l) return l:gsub('^(%s*%- )%(%s*%)', '%1(x)') end
  local function bulletToBlank(l) return l:gsub('^(%s*%- )%(x%)', '%1( )') end

  local function insertLabel(line, label)
    local prefix = line:match '^(%s*%- %([x ]%))'
    if not prefix then return line end
    return prefix .. ' ' .. label .. line:sub(#prefix + 1)
  end

  local function removeLabel(line) return line:gsub('^(%s*%- %([x ]%))%s+`.-`', '%1') end

  ---------------------------------------------------------------------------
  -- 5. Replace every label in the whole chunk (line 1 handled separately)
  ---------------------------------------------------------------------------
  local function relabelChunk(from_pat, to_label)
    for i = 2, #chunk do
      chunk[i] = chunk[i]:gsub(from_pat, to_label)
    end
  end

  ---------------------------------------------------------------------------
  -- 6. Core move helper
  ---------------------------------------------------------------------------
  local function move_chunk_to(ls, target_heading, anchor_heading)
    for i = chunk_end, chunk_start, -1 do
      table.remove(ls, i + 1)
    end

    local hdg_idx
    for i, line in ipairs(ls) do
      if line == target_heading then
        hdg_idx = i
        break
      end
    end

    if not hdg_idx then
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
        if anchor_idx > 1 and ls[anchor_idx - 1] ~= '' then
          table.insert(ls, anchor_idx, '')
          anchor_idx = anchor_idx + 1
        end
        table.insert(ls, anchor_idx, target_heading)
        hdg_idx = anchor_idx
      else
        if ls[#ls] ~= '' then table.insert(ls, '') end
        table.insert(ls, target_heading)
        hdg_idx = #ls
      end
    end

    for j = #chunk, 1, -1 do
      table.insert(ls, hdg_idx + 1, chunk[j])
    end

    local after = hdg_idx + #chunk + 1
    if ls[after] == '' then table.remove(ls, after) end

    return ls
  end

  ---------------------------------------------------------------------------
  -- 7. Main toggle logic
  ---------------------------------------------------------------------------
  if has_done_index then
    -- (x) `done: …`  →  ( ) `untoggled`  →  move to * Incomplete Tasks
    chunk[1] = bulletToBlank(chunk[1])
    chunk[1] = removeLabel(chunk[1])
    chunk[1] = insertLabel(chunk[1], '`untoggled`')
    relabelChunk('`' .. label_done .. '.-`', '`untoggled`')

    lines = move_chunk_to(lines, heading_incomplete, heading_completed)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.notify('Untoggled', vim.log.levels.INFO)
  elseif has_untoggled_index then
    -- ( ) `untoggled`  →  (x) `done: …`  →  move to * Completed Tasks
    local done_label = '`' .. label_done .. ' ' .. timestamp .. '`'
    chunk[1] = bulletToX(chunk[1])
    chunk[1] = removeLabel(chunk[1])
    chunk[1] = insertLabel(chunk[1], done_label)
    relabelChunk('`untoggled`', done_label)

    lines = move_chunk_to(lines, heading_completed, nil)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.notify('Completed', vim.log.levels.INFO)
  else
    -- ( ) (no label)  →  (x) `done: …`  →  move to * Completed Tasks
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

return M
