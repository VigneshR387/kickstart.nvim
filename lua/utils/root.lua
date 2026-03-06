local M = {}

setmetatable(M, {
  __call = function(_, ...) return M.get(...) end,
})

local function lsp_root(buf)
  local clients = vim.lsp.get_clients { bufnr = buf }
  for _, client in ipairs(clients) do
    if client.config.root_dir then return client.config.root_dir end
  end
end

local function git_root(buf)
  local file = vim.api.nvim_buf_get_name(buf)
  if file == '' then return nil end
  return vim.fs.root(file, { '.git' })
end

function M.get(opts)
  opts = opts or {}
  local buf = opts.buf or vim.api.nvim_get_current_buf()

  local root = lsp_root(buf)
  if root then return root end

  root = git_root(buf)
  if root then return root end

  return vim.uv.cwd()
end

function M.git() return git_root(vim.api.nvim_get_current_buf()) or vim.uv.cwd() end

return M
