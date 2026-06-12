local M = {}

M.defaults = {
  key = "<leader>lb",

  position = "float",

  width = 0.85,
  height = 0.85,

  split_size = 40,

  binary = "backlog",

  extra_args = {},
}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

return M
