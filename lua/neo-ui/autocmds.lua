local M = {}

function M.augroup(name, opts)
  vim.api.nvim_create_augroup("neo-ui_" .. name, opts or {})
  return "neo-ui_" .. name
end

-- highlight text on yank qol
vim.api.nvim_create_autocmd("TextYankPost", {
  group = M.augroup("highlight_yank"),
  callback = function()
    vim.hl.on_yank({ higroup = "Search" })
  end,
})

return M
