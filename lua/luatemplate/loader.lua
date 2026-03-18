local config = require("luatemplate.config")

local M = {}
-- _name -> hidden_template
function M.get_templates()
  local all = vim.fn.readdir(config.templates_dir)
  local visible = {}
  for _, f in ipairs(all) do
    if not f:match("^_") then
      table.insert(visible, f)
    end
  end
  return visible
end

function M.load_template(template_name)
  local template_path = config.templates_dir .. "/" .. template_name
  if template_name:match("%.lua$") then
    return dofile(template_path) -- возвращает функцию
  else
    local lines = vim.fn.readfile(template_path)
    return function(ctx)
      return lines
    end
  end
end

return M
