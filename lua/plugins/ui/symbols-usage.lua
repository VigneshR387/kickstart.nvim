return {
  'Wansmer/symbol-usage.nvim',
  event = 'BufReadPre', -- need run before LspAttach if you use nvim 0.9. On 0.10 use 'LspAttach'
  opts = {
    vt_position = 'above',
    vt_priority = nil, ---@type integer Virtual text priority (see `nvim_buf_set_extmark`)

    ---Text to display when request is pending. If `false`, extmark will not be
    ---created until the request is finished. Recommended to use with `above`
    ---vt_position to avoid "jumping lines".
    ---@type string|table|false
    request_pending_text = 'loading...',

    references = { enabled = true, include_declaration = false },
    definition = { enabled = false },
    implementation = { enabled = false },

    ---@type { lsp?: string[], filetypes?: string[], cond?: function[] } Disables `symbol-usage.nvim' for specific LSPs, filetypes, or on custom conditions.
    ---The function in the `cond` list takes an argument `bufnr` and returns a boolean. If it returns true, `symbol-usage` will not run in that buffer.
    disable = { lsp = {}, filetypes = {}, cond = {} },

    text_format = Util['symbols-usage'].text_format,
    log = { enabled = false },
  },
}
