-- Utility module providing helper functions for plugin management,
-- configuration helpers, notifications, memoization, and lazy loading.

-- Import utility functions from lazy.nvim's core utilities

local LazyUtil = require 'lazy.core.util'

-- Main module table
local M = {}

-- Load deprecated helper utilities
M.deprecated = require 'util.deprecated'

-- Metatable that enables dynamic module loading
setmetatable(M, {
  __index = function(t, k)
    -- If lazy.nvim util already has this key, reuse it
    if LazyUtil[k] then return LazyUtil[k] end

    -- If this is a deprecated utility, call its replacement wrapper
    if M.deprecated[k] then return M.deprecated[k]() end

    -- Dynamically load utility submodules.
    -- Example:
    -- Util.cmp → require("util.cmp")
    ---@diagnostic disable-next-line: no-unknown
    t[k] = require('util.' .. k)

    -- decorate the loaded module for deprecated handling
    M.deprecated.decorate(k, t[k])

    return t[k]
  end,
})

-- Check if running on Windows
function M.is_win() return vim.uv.os_uname().sysname:find 'Windows' ~= nil end

-- Get plugin spec from lazy.nvim by plugin name
---@param name string
function M.get_plugin(name) return require('lazy.core.config').spec.plugins[name] end

-- Get path to a plugin directory (optionally append a subpath)
---@param name string
---@param path string?
function M.get_plugin_path(name, path)
  local plugin = M.get_plugin(name)
  path = path and '/' .. path or ''
  return plugin and (plugin.dir .. path)
end

-- Check if a plugin exists in the lazy.nvim spec
---@param plugin string
function M.has(plugin) return M.get_plugin(plugin) ~= nil end

-- -- Check if a Util "extra" module is enabled
-- ---@param extra string
-- function M.has_extra(extra)
--   local Config = require 'lazyvim.config'
--   local modname = 'lazyvim.plugins.extras.' .. extra
--   local LazyConfig = require 'lazy.core.config'
--
--   -- check if module already imported
--   if vim.tbl_contains(LazyConfig.spec.modules, modname) then return true end
--
--   -- check if enabled through LazyExtras
--   if vim.tbl_contains(Config.json.data.extras, modname) then return true end
--
--   -- check if user imported it manually
--   local spec = LazyConfig.options.spec
--   if type(spec) == 'table' then
--     for _, s in ipairs(spec) do
--       if type(s) == 'table' and s.import == modname then return true end
--     end
--   end
--
--   return false
-- end

-- Run a function after the lazy.nvim "VeryLazy" event
---@param fn fun()
function M.on_very_lazy(fn)
  vim.api.nvim_create_autocmd('User', {
    pattern = 'VeryLazy',
    callback = function() fn() end,
  })
end

-- Extend nested tables using a dot-separated key
-- Example: extend(t, "a.b.c", values)
---@generic T
---@param t T[]
---@param key string
---@param values T[]
---@return T[]?
function M.extend(t, key, values)
  local keys = vim.split(key, '.', { plain = true })

  for i = 1, #keys do
    local k = keys[i]

    -- create nested table if it doesn't exist
    t[k] = t[k] or {}

    if type(t) ~= 'table' then return end

    t = t[k]
  end

  return vim.list_extend(t, values)
end

-- Get plugin options from lazy.nvim config
---@param name string
function M.opts(name)
  local plugin = M.get_plugin(name)
  if not plugin then return {} end

  local Plugin = require 'lazy.core.plugin'
  return Plugin.values(plugin, 'opts', false)
end

-- Show deprecation warning
function M.deprecate(old, new, opts)
  M.warn(
    ('`%s` is deprecated. Please use `%s` instead'):format(old, new),
    vim.tbl_extend('force', {
      title = 'NeoVim',
      once = true,
      stacktrace = true,
      stacklevel = 6,
    }, opts or {})
  )
end

-- Delay notifications until vim.notify is replaced
function M.lazy_notify()
  local notifs = {}

  local function temp(...) table.insert(notifs, vim.F.pack_len(...)) end

  local orig = vim.notify
  vim.notify = temp

  local timer = vim.uv.new_timer()
  local check = assert(vim.uv.new_check())

  local replay = function()
    timer:stop()
    check:stop()

    -- restore original notify
    if vim.notify == temp then vim.notify = orig end

    -- replay stored notifications
    vim.schedule(function()
      for _, notif in ipairs(notifs) do
        vim.notify(vim.F.unpack_len(notif))
      end
    end)
  end

  -- wait until notify is replaced
  check:start(function()
    if vim.notify ~= temp then replay() end
  end)

  -- fallback timeout
  timer:start(500, 0, replay)
end

-- Check if plugin is loaded
function M.is_loaded(name)
  local Config = require 'lazy.core.config'
  return Config.plugins[name] and Config.plugins[name]._.loaded
end

-- Run callback when a plugin loads
function M.on_load(name, fn)
  if M.is_loaded(name) then
    fn(name)
  else
    vim.api.nvim_create_autocmd('User', {
      pattern = 'LazyLoad',
      callback = function(event)
        if event.data == name then
          fn(name)
          return true
        end
      end,
    })
  end
end

-- Safe wrapper around keymap creation
-- Prevents conflicts with lazy key handlers
function M.safe_keymap_set(mode, lhs, rhs, opts)
  local keys = require('lazy.core.handler').handlers.keys

  local modes = type(mode) == 'string' and { mode } or mode

  modes = vim.tbl_filter(function(m) return not (keys.have and keys:have(lhs, m)) end, modes)

  if #modes > 0 then
    opts = opts or {}
    opts.silent = opts.silent ~= false

    -- remove remap in some contexts
    if opts.remap and not vim.g.vscode then opts.remap = nil end

    Snacks.keymap.set(modes, lhs, rhs, opts)
  end
end

-- Remove duplicate items from list
function M.dedup(list)
  local ret = {}
  local seen = {}

  for _, v in ipairs(list) do
    if not seen[v] then
      table.insert(ret, v)
      seen[v] = true
    end
  end

  return ret
end

-- Key sequence to create undo break
M.CREATE_UNDO = vim.api.nvim_replace_termcodes('<c-G>u', true, true, true)

-- Insert undo break if in insert mode
function M.create_undo()
  if vim.api.nvim_get_mode().mode == 'i' then vim.api.nvim_feedkeys(M.CREATE_UNDO, 'n', false) end
end

-- Get path to Mason package
function M.get_pkg_path(pkg, path, opts)
  pcall(require, 'mason')

  local root = vim.env.MASON or (vim.fn.stdpath 'data' .. '/mason')

  opts = opts or {}
  opts.warn = opts.warn == nil and true or opts.warn
  path = path or ''

  local ret = vim.fs.normalize(root .. '/packages/' .. pkg .. '/' .. path)

  -- warn if package path missing
  if opts.warn then
    vim.schedule(function()
      if not require('lazy.core.config').headless() and not vim.loop.fs_stat(ret) then
        M.warn(('Mason package path not found for **%s**:\n- `%s`\nYou may need to force update the package.'):format(pkg, path))
      end
    end)
  end

  return ret
end

-- Wrap Util notifications to set NeoVim as title
for _, level in ipairs { 'info', 'warn', 'error' } do
  M[level] = function(msg, opts)
    opts = opts or {}
    opts.title = opts.title or 'Neovim'
    return LazyUtil[level](msg, opts)
  end
end

-- Function result cache
local cache = {}

-- Memoization helper
function M.memoize(fn)
  return function(...)
    local key = vim.inspect { ... }

    cache[fn] = cache[fn] or {}

    if cache[fn][key] == nil then cache[fn][key] = fn(...) end

    return cache[fn][key]
  end
end

-- Safe wrapper around snacks.statuscolumn
function M.statuscolumn() return package.loaded.snacks and require('snacks.statuscolumn').get() or '' end

-- Track default options
local _defaults = {}

-- Safely set default option values
function M.set_default(option, value)
  local l = vim.api.nvim_get_option_value(option, { scope = 'local' })
  local g = vim.api.nvim_get_option_value(option, { scope = 'global' })

  _defaults[('%s=%s'):format(option, value)] = true
  local key = ('%s=%s'):format(option, l)

  local source = ''

  -- if option was changed by plugin, don't override
  if l ~= g and not _defaults[key] then
    local info = vim.api.nvim_get_option_info2(option, { scope = 'local' })

    local scriptinfo = vim.tbl_filter(function(e) return e.sid == info.last_set_sid end, vim.fn.getscriptinfo())

    source = scriptinfo[1] and scriptinfo[1].name or ''

    local by_rtp = #scriptinfo == 1 and vim.startswith(scriptinfo[1].name, vim.fn.expand '$VIMRUNTIME')

    if not by_rtp then
      if vim.g.util_debug_set_default then
        Util.warn(('Not setting option `%s` to `%q` because it was changed by a plugin.'):format(option, value), { title = 'Neovim', once = true })
      end
      return false
    end
  end

  vim.api.nvim_set_option_value(option, value, { scope = 'local' })

  return true
end

-- Export the module
return M
