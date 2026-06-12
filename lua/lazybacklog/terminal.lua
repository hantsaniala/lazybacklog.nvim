local config = require("lazybacklog.config")

local M = {}

M.bufnr = nil
M.winid = nil

local function find_backlog_root()
  local cwd = vim.fn.getcwd()
  local dir = cwd
  while true do
    local test_path = dir .. "/.backlog"
    local stat = vim.loop.fs_stat(test_path)
    if stat and stat.type == "directory" then
      return test_path
    end
    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir then
      return nil
    end
    dir = parent
  end
end

local function build_cmd()
  local opts = config.options
  local bin = vim.fn.executable(opts.binary) == 1 and opts.binary or nil
  if not bin then
    local candidates = {
      vim.fn.expand("~/go/bin/backlog"),
      "/usr/local/bin/backlog",
      "/opt/homebrew/bin/backlog",
    }
    for _, p in ipairs(candidates) do
      if vim.fn.executable(p) == 1 then
        bin = p
        break
      end
    end
  end
  if not bin then
    vim.notify("LazyBacklog: backlog binary not found on PATH. Run 'go install github.com/hantsaniala/backlog@latest'", vim.log.levels.ERROR)
    return nil
  end

  local args = { bin }

  local backlog_root = find_backlog_root()
  if backlog_root then
    vim.fn.extend(args, { "--path", backlog_root })
  end

  args[#args + 1] = "--editor"
  args[#args + 1] = "nvim --remote-send"

  for _, a in ipairs(opts.extra_args) do
    args[#args + 1] = a
  end

  return args
end

local function create_floating(backlog_root)
  local opts = config.options
  local ui = vim.api.nvim_list_uis()[1]
  if not ui then
    return nil
  end

  local width = math.floor(ui.width * opts.width)
  local height = math.floor(ui.height * opts.height)
  local row = math.floor((ui.height - height) / 2)
  local col = math.floor((ui.width - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " LazyBacklog " .. (backlog_root or ""),
    title_pos = "center",
  })

  vim.api.nvim_win_set_option(win, "winhl", "Normal:NormalFloat,FloatBorder:FloatBorder")
  vim.api.nvim_buf_set_keymap(buf, "t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, "t", "q", [[<C-\><C-n>:q<CR>]], { nowait = true, noremap = true, silent = true })

  return buf, win
end

local function create_split(backlog_root, dir)
  local opts = config.options
  local buf = vim.api.nvim_create_buf(false, true)

  local win
  if dir == "right" or dir == "left" then
    win = vim.api.nvim_open_win(buf, true, {
      split = dir,
      win = 0,
      width = opts.split_size,
    })
  else
    win = vim.api.nvim_open_win(buf, true, {
      split = dir == "top" and "above" or "below",
      win = 0,
      height = opts.split_size,
    })
  end

  vim.api.nvim_buf_set_keymap(buf, "t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, "t", "q", [[<C-\><C-n>:close<CR>]], { nowait = true, noremap = true, silent = true })

  return buf, win
end

function M.open()
  if M.winid and vim.api.nvim_win_is_valid(M.winid) then
    vim.api.nvim_set_current_win(M.winid)
    return
  end

  local args = build_cmd()
  if not args then
    return
  end

  local backlog_root = find_backlog_root()
  local buf, win

  if config.options.position == "float" then
    buf, win = create_floating(backlog_root)
  else
    buf, win = create_split(backlog_root, config.options.position)
  end

  if not buf or not win then
    vim.notify("LazyBacklog: failed to create window", vim.log.levels.ERROR)
    return
  end

  M.bufnr = buf
  M.winid = win

  local cmd_str = vim.fn.join(args, " ")
  vim.fn.termopen(cmd_str, {
    on_exit = function()
      vim.schedule(function()
        if M.winid and vim.api.nvim_win_is_valid(M.winid) then
          vim.api.nvim_win_close(M.winid, true)
        end
        M.winid = nil
        M.bufnr = nil
      end)
    end,
  })

  vim.cmd("startinsert")
end

function M.close()
  if M.winid and vim.api.nvim_win_is_valid(M.winid) then
    vim.api.nvim_win_close(M.winid, true)
  end
  M.winid = nil
  M.bufnr = nil
end

function M.toggle()
  if M.winid and vim.api.nvim_win_is_valid(M.winid) then
    M.close()
  else
    M.open()
  end
end

return M
