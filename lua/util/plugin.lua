local Meta = require 'lazy.core.meta'
local Plugin = require 'lazy.core.plugin'

---@class lazyvim.util.plugin
local M = {}

---@type string[]
M.core_imports = {}
M.handle_defaults = true

M.lazy_file_events = { 'BufReadPost', 'BufNewFile', 'BufWritePre' }

M.renames = {
  ['windwp/nvim-spectre'] = 'nvim-pack/nvim-spectre',
  ['jose-elias-alvarez/null-ls.nvim'] = 'nvimtools/none-ls.nvim',
  ['null-ls.nvim'] = 'none-ls.nvim',
  ['romgrk/nvim-treesitter-context'] = 'nvim-treesitter/nvim-treesitter-context',
  ['glepnir/dashboard-nvim'] = 'nvimdev/dashboard-nvim',
  ['markdown.nvim'] = 'render-markdown.nvim',
  ['williamboman/mason.nvim'] = 'mason-org/mason.nvim',
  ['williamboman/mason-lspconfig.nvim'] = 'mason-org/mason-lspconfig.nvim',
}

function M.setup()
  M.fix_renames()
  M.lazy_file()
end

function M.fix_renames()
  ---@param plugin LazyPluginSpec
  Meta.add = Util.inject.args(Meta.add, function(self, plugin)
    if type(plugin) == 'table' then
      local name = plugin[1]
      if not name then return end
      if name:find 'echasnovski' then M.renames[name] = name:gsub('echasnovski', 'nvim-mini') end
      if M.renames[name] then
        Util.warn(
          ('Plugin `%s` was renamed to `%s`.\nPlease update your config for `%s`'):format(plugin[1], M.renames[plugin[1]], self.importing or 'Neovim'),
          { title = 'Lazy' }
        )
        plugin[1] = M.renames[name]
      end
    end
  end)
end

function M.lazy_file()
  -- Add support for the LazyFile event
  local Event = require 'lazy.core.handler.event'

  Event.mappings.LazyFile = { id = 'LazyFile', event = M.lazy_file_events }
  Event.mappings['User LazyFile'] = Event.mappings.LazyFile
end

return M
