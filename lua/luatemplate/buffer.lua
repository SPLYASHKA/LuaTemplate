local loader = require("luatemplate.loader")

local M = {}

-- create new buffer and paste template
function M.create_buffer_from_template(template_name)
  local bufnr = vim.api.nvim_create_buf(true, false) -- новый буфер
  local ctx = {
    filename = nil,
    cwd = vim.fn.getcwd(),
    bufnr = bufnr,
  }

  local template_fn = loader.load_template(template_name)

  local co = coroutine.wrap(function()
    local lines = template_fn(ctx)

    if type(lines) == "string" then
      lines = vim.split(lines, "\n", true)
    end

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.api.nvim_set_current_buf(bufnr)
    if ctx.filename and ctx.filename ~= "" then
      -- FIX: potencial multinline filename
      vim.api.nvim_buf_set_name(bufnr, ctx.filename)
    end
  end)

  co()
end

return M
