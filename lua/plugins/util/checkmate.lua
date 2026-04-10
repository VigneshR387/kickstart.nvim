return {
  'bngarren/checkmate.nvim',
  ft = 'markdown', -- Lazy loads for Markdown files matching patterns in 'files'
  opts = {
    enabled = true,
    notify = true,
    -- Default file matching:
    --  - Any `todo` or `TODO` file, including with `.md` extension
    --  - Any `.todo` extension (can be ".todo" or ".todo.md")
    -- To activate Checkmate, the filename must match AND the filetype must be "markdown"
    files = {
      '*.md',
      'todo',
      'TODO',
      'todo.md',
      'TODO.md',
      '*.todo',
      '*.todo.md',
    },
    log = {
      level = 'warn',
      use_file = true,
    },
    -- Default keymappings
    keys = {
      ['<leader>tt'] = {
        rhs = '<cmd>Checkmate toggle<CR>',
        desc = 'Toggle todo item',
        modes = { 'n', 'v' },
      },
      ['<leader>tc'] = {
        rhs = '<cmd>Checkmate check<CR>',
        desc = 'Set todo item as checked (done)',
        modes = { 'n', 'v' },
      },
      ['<leader>tu'] = {
        rhs = '<cmd>Checkmate uncheck<CR>',
        desc = 'Set todo item as unchecked (not done)',
        modes = { 'n', 'v' },
      },
      ['<leader>t='] = {
        rhs = '<cmd>Checkmate cycle_next<CR>',
        desc = 'Cycle todo item(s) to the next state',
        modes = { 'n', 'v' },
      },
      ['<leader>t-'] = {
        rhs = '<cmd>Checkmate cycle_previous<CR>',
        desc = 'Cycle todo item(s) to the previous state',
        modes = { 'n', 'v' },
      },
      ['<leader>tn'] = {
        rhs = '<cmd>Checkmate create<CR>',
        desc = 'Create todo item',
        modes = { 'n', 'v' },
      },
      ['<leader>tr'] = {
        rhs = '<cmd>Checkmate remove<CR>',
        desc = 'Remove todo marker (convert to text)',
        modes = { 'n', 'v' },
      },
      ['<leader>tR'] = {
        rhs = '<cmd>Checkmate remove_all_metadata<CR>',
        desc = 'Remove all metadata from a todo item',
        modes = { 'n', 'v' },
      },
      ['<leader>ta'] = {
        rhs = '<cmd>Checkmate archive<CR>',
        desc = 'Archive checked/completed todo items (move to bottom section)',
        modes = { 'n' },
      },
      ['<leader>tF'] = {
        rhs = '<cmd>Checkmate select_todo<CR>',
        desc = 'Open a picker to select a todo from the current buffer',
        modes = { 'n' },
      },
      ['<leader>tv'] = {
        rhs = '<cmd>Checkmate metadata select_value<CR>',
        desc = 'Update the value of a metadata tag under the cursor',
        modes = { 'n' },
      },
      ['<leader>t]'] = {
        rhs = '<cmd>Checkmate metadata jump_next<CR>',
        desc = 'Move cursor to next metadata tag',
        modes = { 'n' },
      },
      ['<leader>t['] = {
        rhs = '<cmd>Checkmate metadata jump_previous<CR>',
        desc = 'Move cursor to previous metadata tag',
        modes = { 'n' },
      },
      ['<M-x>'] = {
        rhs = '<cmd>Checkmate metadata toggle done<CR>',
        desc = 'Toggle Metadata @done',
        modes = { 'n', 'v' },
      },
      ['<M-i>'] = {
        rhs = '<cmd>Checkmate create<CR>',
        desc = 'Create todo item',
        modes = { 'n', 'v' },
      },
    },
    default_list_marker = '-',
    ui = {},
    todo_states = {
      -- we don't need to set the `markdown` field for `unchecked` and `checked` as these can't be overriden
      ---@diagnostic disable-next-line: missing-fields
      unchecked = {
        -- marker = '[ ]',
        marker = '□',
        order = 1,
      },
      ---@diagnostic disable-next-line: missing-fields
      checked = {
        -- marker = '[x]',
        marker = '✔',
        order = 2,
      },
      -- Custom states
      -- in_progress = {
      --   marker = '◐',
      --   markdown = '.', -- Saved as `- [.]`
      --   type = 'incomplete', -- Counts as "not done"
      --   order = 50,
      -- },
      -- cancelled = {
      --   marker = '✗',
      --   markdown = 'c', -- Saved as `- [c]`
      --   type = 'complete', -- Counts as "done"
      --   order = 2,
      -- },
      -- on_hold = {
      --   marker = '⏸',
      --   markdown = '/', -- Saved as `- [/]`
      --   type = 'inactive', -- Ignored in counts
      --   order = 100,
      -- },
    },
    style = {}, -- override defaults
    enter_insert_after_new = true, -- Should enter INSERT mode after `:Checkmate create` (new todo)
    list_continuation = {
      enabled = true,
      split_line = true,
      keys = {
        ['<CR>'] = function()
          require('checkmate').create {
            position = 'below',
            indent = false,
          }
        end,
        ['<S-CR>'] = function()
          require('checkmate').create {
            position = 'below',
            indent = true,
          }
        end,
      },
    },
    smart_toggle = {
      enabled = true,
      include_cycle = false,
      check_down = 'direct_children',
      uncheck_down = 'none',
      check_up = 'direct_children',
      uncheck_up = 'direct_children',
    },
    show_todo_count = true,
    todo_count_position = 'eol',
    todo_count_recursive = true,
    use_metadata_keymaps = true,
    metadata = {
      -- Example: A @priority tag that has dynamic color based on the priority value
      priority = {
        style = function(context)
          local value = context.value:lower()
          if value == 'high' then
            return { fg = '#ff5555', bold = true }
          elseif value == 'medium' then
            return { fg = '#ffb86c' }
          elseif value == 'low' then
            return { fg = '#8be9fd' }
          else -- fallback
            return { fg = '#8be9fd' }
          end
        end,
        get_value = function()
          return 'medium' -- Default priority
        end,
        choices = function() return { 'low', 'medium', 'high' } end,
        key = '<leader>tp',
        sort_order = 10,
        jump_to_on_insert = 'value',
        select_on_insert = true,
      },
      -- Example: A @started tag that uses a default date/time string when added
      started = {
        aliases = { 'init' },
        style = { fg = '#9fd6d5' },
        get_value = function() return tostring(os.date '%m/%d/%y %H:%M') end,
        key = '<leader>ts',
        sort_order = 20,
      },
      -- Example: A @done tag that also sets the todo item state when it is added and removed
      done = {
        aliases = { 'completed', 'finished' },
        style = { fg = '#96de7a' },
        get_value = function() return tostring(os.date '%m/%d/%y %H:%M') end,
        key = '<leader>td',
        on_add = function(todo) require('checkmate').set_todo_state(todo, 'checked') end,
        on_remove = function(todo) require('checkmate').set_todo_state(todo, 'unchecked') end,
        sort_order = 30,
      },
      -- Due metadata (include time)
      -- due = {
      --   key = '<leader>Td',
      --   sort_order = 10,
      --
      --   -- Default: tomorrow at 9:00 AM
      --   get_value = function()
      --     local t = os.date '*t'
      --     t.day = t.day + 1
      --     t.hour = 9
      --     t.min = 0
      --     t.sec = 0
      --     return os.date('%m/%d/%y %H:%M', os.time(t))
      --   end,
      --
      --   jump_to_on_insert = 'value',
      --   select_on_insert = true,
      --
      --   -- Preset choices with time baked in
      --   choices = function(_, callback)
      --     local function fmt(offset_days, hour)
      --       local t = os.date '*t'
      --       t.day = t.day + offset_days
      --       t.hour = hour or 9
      --       t.min = 0
      --       t.sec = 0
      --       return os.date('%m/%d/%y %H:%M', os.time(t))
      --     end
      --
      --     -- NOTE: PICK ONE OF THE SETUP
      --     local n = 14 -- how many days out
      --     local times = { 9, 12, 17 }
      --     local items = {}
      --
      --     for day = 0, n do
      --       for _, hour in ipairs(times) do
      --         table.insert(items, fmt(day, hour))
      --       end
      --     end
      --
      --     callback(items)
      --     -- callback {
      --     --   fmt(0, 9), -- today 9 AM
      --     --   fmt(0, 12), -- today noon
      --     --   fmt(0, 17), -- today 5 PM
      --     --   fmt(1, 9), -- tomorrow 9 AM
      --     --   fmt(1, 17), -- tomorrow 5 PM
      --     --   fmt(3, 9), -- in 3 days
      --     --   fmt(7, 9), -- next week
      --     --   fmt(14, 9), -- in 2 weeks
      --     --   fmt(30, 9), -- in a month
      --     -- }
      --   end,
      --
      --   -- Urgency now accounts for hours, not just days
      --   style = function(context)
      --     local value = context.value or ''
      --
      --     -- Parse MM/DD/YY HH:MM (time is optional)
      --     local m, d, y, h, min = value:match '^(%d+)/(%d+)/(%d+) (%d+):(%d+)$'
      --
      --     -- Fall back to date-only if no time component
      --     if not m then
      --       m, d, y = value:match '^(%d+)/(%d+)/(%d+)$'
      --       h, min = 23, 59
      --     end
      --
      --     if not m then
      --       return { fg = '#8be9fd' } -- unparseable → fallback blue
      --     end
      --
      --     local due_ts = os.time {
      --       year = 2000 + tonumber(y),
      --       month = tonumber(m),
      --       day = tonumber(d),
      --       hour = tonumber(h),
      --       min = tonumber(min),
      --       sec = 0,
      --     }
      --
      --     local now = os.time()
      --     local hours_until = (due_ts - now) / 3600
      --
      --     if hours_until < 0 then
      --       return { fg = '#ff5555', bold = true, italic = true } -- overdue
      --     elseif hours_until < 2 then
      --       return { fg = '#ff5555', bold = true } -- due within 2 hours
      --     elseif hours_until < 24 then
      --       return { fg = '#ffb86c', bold = true } -- due today
      --     elseif hours_until < 72 then
      --       return { fg = '#f1fa8c' } -- within 3 days
      --     else
      --       return { fg = '#50fa7b' } -- future
      --     end
      --   end,
      -- },
      -- Due (only date)
      due = {
        key = '<leader>Td',
        sort_order = 10, -- show @due first among metadata tags

        -- Default value: tomorrow's date at midnight
        get_value = function()
          local t = os.date '*t'
          t.day = t.day + 1
          t.hour = 0
          t.min = 0
          t.sec = 0
          return os.date('%m/%d/%y', os.time(t))
        end,

        -- Jump into the value and select it so you can type a new date immediately
        jump_to_on_insert = 'value',
        select_on_insert = true,

        -- Preset choices for quick selection via :Checkmate metadata select_value
        choices = function(_, callback)
          -- Dynamic choices: resolved at selection time
          local function fmt(offset_days)
            local t = os.date '*t'
            t.day = t.day + offset_days
            t.hour = 0
            t.min = 0
            t.sec = 0
            return os.date('%m/%d/%y', os.time(t))
          end
          -- NOTE:  LOOP DAYS OR SET PREDEFINED  (CHOOSE ONE)

          local items = {}
          for i = 0, 14 do
            table.insert(items, fmt(i))
          end
          callback(items)

          -- callback {
          --   fmt(0), -- today
          --   fmt(1), -- tomorrow
          --   fmt(3), -- in 3 days
          --   fmt(7), -- next week
          --   fmt(14), -- in 2 weeks
          --   fmt(30), -- in a month
          -- }
        end,

        -- Color based on urgency: overdue = red, today = orange, soon = yellow, future = green
        style = function(context)
          local value = context.value or ''

          -- Parse MM/DD/YY
          local m, d, y = value:match '^(%d+)/(%d+)/(%d+)$'
          if not m then
            return { fg = '#8be9fd' } -- unparseable → default blue
          end

          local due_ts = os.time {
            year = 2000 + tonumber(y),
            month = tonumber(m),
            day = tonumber(d),
            hour = 23,
            min = 59,
            sec = 59,
          }

          local now = os.time()
          local days_until = (due_ts - now) / 86400

          if days_until < 0 then
            return { fg = '#ff5555', bold = true, italic = true } -- overdue: red + italic
          elseif days_until < 1 then
            return { fg = '#ff5555', bold = true } -- due today: red bold
          elseif days_until <= 3 then
            return { fg = '#ffb86c', bold = true } -- due soon: orange
          elseif days_until <= 7 then
            return { fg = '#f1fa8c' } -- this week: yellow
          else
            return { fg = '#50fa7b' } -- future: green
          end
        end,
      },
    },
    archive = {
      heading = {
        title = 'Completed',
        level = 2, -- e.g. ##
      },
      parent_spacing = 0, -- no extra lines between archived todos
      newest_first = true,
    },
    linter = {
      enabled = true,
    },
  },
}
