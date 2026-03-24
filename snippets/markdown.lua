-- Filename: ~/.config/nvim/snippets/markdown.lua
-- ~/.config/nvim/snippets/markdown.lua

local ls = require 'luasnip'
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local function clipboard() return vim.fn.getreg '+' end

-- Auto-generate fenced code block snippets
local function code_block(lang)
  return s({ trig = lang, name = 'Codeblock', desc = lang .. ' code block' }, {
    t { '```' .. lang, '' },
    i(1),
    t { '', '```' },
  })
end

local languages = {
  'txt',
  'lua',
  'sql',
  'go',
  'regex',
  'bash',
  'markdown',
  'markdown_inline',
  'yaml',
  'json',
  'jsonc',
  'cpp',
  'csv',
  'java',
  'javascript',
  'python',
  'dockerfile',
  'html',
  'css',
}

local snippets = {}

for _, lang in ipairs(languages) do
  table.insert(snippets, code_block(lang))
end

-- chirpy tip block
table.insert(
  snippets,
  s({ trig = 'chirpy', name = 'Chirpy prompt block', desc = 'markdownlint + prettier disabled chirpy prompt' }, {
    t {
      ' ',
      '<!-- markdownlint-disable -->',
      '<!-- prettier-ignore-start -->',
      ' ',
      '<!-- tip=green, info=blue, warning=yellow, danger=red -->',
      ' ',
      '> ',
    },
    i(1),
    t { '', '{: .prompt-' },
    i(2),
    t {
      ' }',
      ' ',
      '<!-- prettier-ignore-end -->',
      '<!-- markdownlint-restore -->',
    },
  })
)

-- markdownlint disable range
table.insert(
  snippets,
  s({ trig = 'markdownlint', name = 'markdownlint disable range', desc = 'Wrap in markdownlint disable/restore' }, {
    t { ' ', '<!-- markdownlint-disable -->', ' ', '> ' },
    i(1),
    t { ' ', ' ', '<!-- markdownlint-restore -->' },
  })
)

-- prettier ignore range
table.insert(
  snippets,
  s({ trig = 'prettier-ignore', name = 'Prettier ignore range', desc = 'Wrap in prettier ignore' }, {
    t { ' ', '<!-- prettier-ignore-start -->', ' ', '> ' },
    i(1),
    t { ' ', ' ', '<!-- prettier-ignore-end -->' },
  })
)

-- regular link
table.insert(snippets, s({ trig = 'link', name = 'Regular link', desc = 'Insert a markdown link' }, { t '[', i(1), t '](', i(2), t ')' }))

-- link in new tab (chirpy theme)
table.insert(
  snippets,
  s({ trig = 'linkt', name = 'Link in new tab', desc = 'Open link in new tab (chirpy)' }, { t '[', i(1), t '](', i(2), t '){:target="_blank"}' })
)

-- link with clipboard as URL
table.insert(
  snippets,
  s({ trig = 'linkc', name = 'Link with clipboard URL', desc = 'Paste clipboard as markdown link' }, { t '[', i(1), t '](', f(clipboard, {}), t ')' })
)

-- external link with clipboard
table.insert(
  snippets,
  s(
    { trig = 'linkex', name = 'External link with clipboard', desc = 'Paste clipboard as external markdown link' },
    { t '[', i(1), t '](', f(clipboard, {}), t '){:target="_blank"}' }
  )
)

-- TODO comment
table.insert(snippets, s({ trig = 'todo', name = 'TODO comment', desc = 'HTML comment TODO item' }, { t '<!-- TODO: ', i(1), t ' -->' }))

-- bash script example
table.insert(
  snippets,
  s({ trig = 'bashex', name = 'Bash script example', desc = 'Simple bash script template' }, {
    t {
      '```bash',
      '#!/bin/bash',
      '',
      "echo 'hello'",
      '```',
      '',
    },
  })
)

-- python script example
table.insert(
  snippets,
  s({ trig = 'pythonex', name = 'Python script example', desc = 'Simple Python script template' }, {
    t {
      '```python',
      '#!/usr/bin/env python3',
      '',
      'def main():',
      "    print('hello')",
      '',
      "if __name__ == '__main__':",
      '    main()',
      '```',
      '',
    },
  })
)

return snippets
