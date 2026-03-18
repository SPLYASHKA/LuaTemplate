local c = {
  templates_dir = vim.fn.stdpath("config") .. "/templates",
}

function c.setup(opts)
  opts = opts or {}
  for k, v in pairs(opts) do
    c[k] = v
  end
end

return c
