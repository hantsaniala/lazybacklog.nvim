local config = require("lazybacklog.config")
local terminal = require("lazybacklog.terminal")

local M = {}

function M.setup(opts)
  config.setup(opts)

  vim.api.nvim_create_user_command("LazyBacklog", function()
    terminal.toggle()
  end, { desc = "Toggle LazyBacklog window" })

  vim.api.nvim_create_user_command("LazyBacklogOpen", function()
    terminal.open()
  end, { desc = "Open LazyBacklog window" })

  vim.api.nvim_create_user_command("LazyBacklogClose", function()
    terminal.close()
  end, { desc = "Close LazyBacklog window" })

  local key = config.options.key
  if key then
    vim.keymap.set("n", key, function()
      terminal.toggle()
    end, { desc = "Toggle LazyBacklog" })
  end
end

return M
