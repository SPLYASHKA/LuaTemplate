# LuaTemplate

Dynamic template system for Neovim.
Create new buffers from templates with support for Lua logic, support nested templates, and asynchronous UI selection.

## Features

- Templates as **Lua functions** or **plain text files**.
- Shared **context** for passing data between templates
- Nested templates supported.
- Async selection with vim.ui.select.

## Setup

### Install

- With your preferred plugin manager

**lazy:**
```lua
{
  "splyashka/LuaTemplate",
  opts = {},
  -- example keymaps
  keys = {
    {
      "<leader>n",
      function()
        require("luatemplate").pick_template()
      end,
      desc = "New from template"
    }
  }
}
```

### Configuration

```lua
require("luatemplate").setup({
  -- default options
  templates_dir = vim.fn.stdpath("config") .. "/templates", -- path to templates
})
```

## Add template

### Static text file

> All non *.lua files

`example.md` in `templates_dir`:
```
# Example Template
Hello from LuaTemplate!
```

### Lua template (basic)

```lua
return function(ctx)
  ctx.filename = "example.md"

  return {
    "Line 1",
    "Line 2",
    "CWD:" .. ctx.cwd,
    "TIME: " .. os.date()
  }
end
```

or:

```lua
return function(ctx)
  ctx.filename = "multiline_strings.md"

  return [[Line 1
Line 2
Line 3]]
end
```

### Lua template with user choice

```lua
local lt = require("luatemplate")

return function(ctx)
  local options = { "Option A", "Option B", "Option C" }

  local choice = lt.ui_select(options, {
    prompt = "Select option:",
  })

  ctx.filename = "note_" .. choice

  return "You selected: " .. choice
end
```

### Nested templates
Templates can call other templates — even in a recursive manner.
This allows building complex dynamic structures (e.g. trees, repeated sections, generators).

Just be careful to avoid infinite recursion.

> Files prefixed with _ are hidden from the picker.


`_child.lua`:
```lua
return function(ctx)
  ctx.value = "from child"

  return {
    "Child line 1",
    "Child line 2",
  }
end
```
`parent.lua`:
```lua
local lt = require("luatemplate")

return function(ctx)
  local child = lt.load_template("_child.lua")

  local lines = {
    "Parent line 1",
  }

  local child_lines = child(ctx)

  vim.list_extend(lines, child_lines)

  vim.list_extend(lines, {
    "Parent line 2",
    "Value: " .. ctx.value,
  })

  return lines
end
```

Result:

```
Parent line 1
Child line 1
Child line 2
Parent line 2
Value: from child
```

### Cursor positioning

You can move the cursor after the template is applied using `vim.schedule`:

```lua
return function(ctx)
  local lines = {
    "Line 1",
    "Line 2",
    "Line 3",
  }

  vim.schedule(function()
    -- move cursor to last line
    vim.api.nvim_win_set_cursor(0, { #lines, 0 })
  end)

  return lines
end
```


### API

```lua
local lt = require("luatemplate")

-- Pick a template and create a buffer
lt.pick_template()

-- Load template function (can be Lua or static file)
local fn = lt.load_template("my_template.lua")
local lines = fn(ctx)

-- Get list of visible templates (without _ prefix)
local list = lt.get_templates()

-- Async select helper (you can )
local ui_select = lt.ui_select({"A", "B", "C"}, { prompt = "Choose:" })
```

### UI (vim.ui.select)

LuaTemplate uses Neovim’s built-in `vim.ui.select` for user interaction.

This means you can **change the UI globally** by installing another plugin.

**Examples:**

- [telescope-ui-select](https://github.com/nvim-telescope/telescope-ui-select.nvim)
- [snacks.nvim](https://github.com/folke/snacks.nvim)
- [dressing.nvim](https://github.com/stevearc/dressing.nvim)

These plugins override **vim.ui.select**, so LuaTemplate will automatically use them.

## License

This plugin is released under the **MIT License**. See [LICENSE](./LICENSE) for details.
