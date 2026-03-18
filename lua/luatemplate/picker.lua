local buffer = require("luatemplate.buffer")
local loader = require("luatemplate.loader")

local M = {}

function M.pick_template()
  local templates = loader.get_templates()

  local opts = {
    prompt = "Select a template",
  }

  local co = coroutine.create(function()
    local selection = M.ui_select(templates, opts)
    if not selection or selection == vim.NIL then
      return
    end

    buffer.create_buffer_from_template(selection)
  end)

  coroutine.resume(co)
end

function M.ui_select(items, opts)
  local co, is_main = coroutine.running()
  if co and not is_main then
    vim.ui.select(items, opts, function(choice)
      -- schedule to ensure resume doesn't happen _before_ yield with
      -- default synchronous vim.ui.select
      vim.schedule(function()
        coroutine.resume(co, choice or vim.NIL)
      end)
    end)
    return coroutine.yield()
  else
    local choice = vim.fn.inputlist(items)
    if choice < 1 or choice > #items then
      return vim.NIL
    else
      return items[choice]
    end
  end
end

return M
