return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    bigfile = {
      enabled = true,
      notify = true, -- show notification when big file detected
      size = 1.5 * 1024 * 1024, -- 1.5MB
      line_length = 1000, -- average line length (useful for minified files)
      -- Enable or disable features when big file detected
      ---@param ctx {buf: number, ft:string}
      setup = function(ctx)
        if vim.fn.exists ':NoMatchParen' ~= 0 then vim.cmd [[NoMatchParen]] end
        Snacks.util.wo(0, { foldmethod = 'manual', statuscolumn = '', conceallevel = 0 })
        vim.b.completion = false
        vim.b.minianimate_disable = true
        vim.b.minihipatterns_disable = true
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(ctx.buf) then vim.bo[ctx.buf].syntax = ctx.ft end
        end)
      end,
    },
    dim = {
      -- your dim configuration comes here
      -- or leave it empty to use the default settings
      animate = {
        enabled = vim.fn.has 'nvim-0.10' == 1,
        easing = 'outQuad',
        duration = {
          step = 50, -- ms per step
          total = 300, -- maximum duration
        },
      },
    },
    gh = {
      -- your gh configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    picker = {
      enabled = true, -- Enhances Select
      win = {
        input = {
          keys = {
            ['<a-a>'] = { 'opencode_send', mode = { 'n', 'i' } },
          },
        },
      },
      actions = {
        opencode_send = function(picker) ---@param picker snacks.Picker
          local items = vim.tbl_map(function(item) ---@param item snacks.picker.Item
            return item.file and require('opencode').format { path = item.file, from = item.pos, to = item.end_pos } or item.text
          end, picker:selected { fallback = true })

          require('opencode').prompt(table.concat(items, ', ') .. ' ')
        end,
      },
      sources = {
        gh_issue = {
          -- your gh_issue picker configuration comes here
          -- or leave it empty to use the default settings
        },
        gh_pr = {
          -- your gh_pr picker configuration comes here
          -- or leave it empty to use the default settings
        },
      },
    },
    indent = { enabled = true },
    input = {
      enabled = true,
    },

    image = {
      enabled = true,
      doc = {
        enabled = false,
        inline = false,
        -- render the image in a floating window
        -- only used if `opts.inline` is disabled
        float = true,
        -- Sets the size of the image
        -- max_width = 60,
        -- max_width = vim.g.neovim_mode == "skitty" and 20 or 60,
        -- max_height = vim.g.neovim_mode == "skitty" and 10 or 30,
        max_width = 60,
        max_height = 30,
        -- Apparently, all the images that you preview in neovim are converted
        -- to .png and they're cached, original image remains the same, but
        -- the preview you see is a png converted version of that image
        --
        -- Where are the cached images stored?
        -- This path is found in the docs
        -- :lua print(vim.fn.stdpath("cache") .. "/snacks/image")
        -- For me returns `~/.cache/neobean/snacks/image`
        -- Go 1 dir above and check `sudo du -sh ./* | sort -hr | head -n 5`
      },
    },
    notifier = { enabled = false },
    quickfile = {
      enabled = true,

      -- any treesitter langs to exclude
      -- exclude = { 'latex' },
    },
    scope = {
      -- your scope configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      enabled = true,
    },
    scroll = {
      enabled = true,
    },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    zen = {},
  },
}
