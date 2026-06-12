if vim.g.loaded_lazybacklog then
  return
end
vim.g.loaded_lazybacklog = true

require("lazybacklog").setup({})
