local M = {}

M.terms = {}

local defaults = {
  float = {
    title = "  Terminal ",
    title_pos = "center",
    relative = "editor",
    border = "rounded",
    width = 0.6,
    height = 0.55,
  },

  hsplit = {
    vertical = false,
    height = 0.3,
  },

  vsplit = {
    vertical = true,
    width = 0.3,
  },
}

local function term_get_by_type(type)
  for _, v in pairs(M.terms) do
    if v.type == type then
      return v
    end
  end
end

local function draw(term)
  local win_opts = vim.deepcopy(defaults[term.type])

  if term.type == "float" then
    win_opts.width = math.ceil(vim.o.columns * win_opts.width)
    win_opts.height = math.ceil(vim.o.lines * win_opts.height)
    win_opts.col = math.ceil((vim.o.columns - win_opts.width) / 2)
    win_opts.row = math.ceil((vim.o.lines - win_opts.height) / 2)
  elseif term.type == "hsplit" then
    win_opts.height = math.ceil(vim.o.lines * win_opts.height)
  elseif term.type == "vsplit" then
    win_opts.width = math.ceil(vim.o.columns * win_opts.width)
  end

  term.win = vim.api.nvim_open_win(term.buf, true, win_opts)
  vim.opt_local.relativenumber = false
  vim.opt_local.number = false
  vim.opt_local.statuscolumn = nil

  vim.cmd("startinsert")
end

local function create(term)
  term.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[term.buf].ft = "toggleterm"

  -- stylua: ignore
  vim.keymap.set("n", "<Esc>", function() vim.api.nvim_win_close(term.win, true) end, { buf = term.buf, desc = "Terminal Close" })
  vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { buf = term.buf, desc = "Terminal Unfocus" })
  vim.api.nvim_create_autocmd("TermClose", {
    buf = term.buf,
    callback = function()
      M.terms[tostring(term.buf)] = nil
      if not (vim.fn.bufwinid(term.buf) == -1) then
        vim.api.nvim_win_close(term.win, true)
        vim.api.nvim_buf_delete(term.buf, { force = true, unload = true })
      end
    end,
  })

  draw(term)
  vim.fn.jobstart(vim.o.shell, {term = true})

  M.terms[tostring(term.buf)] = term -- Save term opts
end

M.toggle = function(opts)
  local term = term_get_by_type(opts.type)

  if not term or not vim.api.nvim_buf_is_valid(term.buf) then
    create(opts)
  elseif vim.fn.bufwinid(term.buf) == -1 then
    draw(term)
  else
    vim.api.nvim_win_close(term.win, true)
  end
end

return M
