local M = {}

M.setup = require("luatemplate.config").setup

local loader = require("luatemplate.loader")
local picker = require("luatemplate.picker")

M.load_template = loader.load_template
M.ui_select = picker.ui_select
M.pick_template = picker.pick_template

return M
