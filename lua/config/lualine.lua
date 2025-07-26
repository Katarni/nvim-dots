local fn = vim.fn

local git_status_cache = {}

local on_exit_fetch = function(result)
  if result.code == 0 then
    git_status_cache.fetch_success = true
  end
end

local function handle_numeric_result(cache_key)
  return function(result)
    if result.code == 0 then
      git_status_cache[cache_key] = tonumber(result.stdout:match("(%d+)")) or 0
    end
  end
end

local async_cmd = function(cmd_str, on_exit)
  local cmd = vim.tbl_filter(function(element)
    return element ~= ""
  end, vim.split(cmd_str, " "))

  vim.system(cmd, { text = true }, on_exit)
end

local async_git_status_update = function()
  -- Fetch the latest changes from the remote repository (replace 'origin' if needed)
  async_cmd("git fetch origin", on_exit_fetch)
  if not git_status_cache.fetch_success then
    return
  end

  -- Get the number of commits behind
  -- the @{upstream} notation is inspired by post: https://www.reddit.com/r/neovim/comments/t48x5i/git_branch_aheadbehind_info_status_line_component/
  -- note that here we should use double dots instead of triple dots
  local behind_cmd_str = "git rev-list --count HEAD..@{upstream}"
  async_cmd(behind_cmd_str, handle_numeric_result("behind_count"))

  -- Get the number of commits ahead
  local ahead_cmd_str = "git rev-list --count @{upstream}..HEAD"
  async_cmd(ahead_cmd_str, handle_numeric_result("ahead_count"))
end

local function get_git_ahead_behind_info()
  async_git_status_update()

  local status = git_status_cache
  if not status then
    return ""
  end

  local msg = ""

  if type(status.ahead_count) == "number" and status.ahead_count > 0 then
    local ahead_str = string.format("↑[%d] ", status.ahead_count)
    msg = msg .. ahead_str
  end

  if type(status.behind_count) == "number" and status.behind_count > 0 then
    local behind_str = string.format("↓[%d] ", status.behind_count)
    msg = msg .. behind_str
  end

  return msg
end

local diff = function()
  local git_status = vim.b.gitsigns_status_dict
  if git_status == nil then
    return
  end

  local modify_num = git_status.changed
  local remove_num = git_status.removed
  local add_num = git_status.added

  local info = { added = add_num, modified = modify_num, removed = remove_num }
  -- vim.print(info)
  return info
end

local get_active_lsp = function()
  local msg = "nothing"
  local buf_ft = vim.api.nvim_get_option_value("filetype", {})
  local clients = vim.lsp.get_clients { bufnr = 0 }
  if next(clients) == nil then
    return msg
  end

  for _, client in ipairs(clients) do
    ---@diagnostic disable-next-line: undefined-field
    local filetypes = client.config.filetypes
    if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
      return client.name
    end
  end
  return msg
end

require("lualine").setup {
  options = {
    icons_enabled = false,
    theme = "auto",
    component_separators = { left = "⏐", right = "⏐" },
    section_separators = "",
    disabled_filetypes = {},
    always_divide_middle = true,
    refresh = {
      statusline = 1000,
    },
  },
  sections = {
    lualine_a = {
      {
        "filename",
        symbols = {
          readonly = "[🔒]",
        },
      },
    },
    lualine_b = {
      {
        "branch",
        fmt = function(name, _)
          -- truncate branch name in case the name is too long
          return string.sub(name, 1, 20)
        end,
        color = { gui = "italic,bold" },
      },
      {
        get_git_ahead_behind_info,
        color = { fg = "#E0C479" },
      },
      {
        "diff",
        source = diff,
      },
    },
    lualine_c = {
      {
        "%S",
        color = { gui = "bold", fg = "cyan" },
      },
    },
    lualine_x = {
      {
        get_active_lsp,
      },
      {
        "diagnostics",
        sources = { "nvim_diagnostic" },
        symbols = { error = "🆇 ", warn = "⚠️ ", info = "ℹ️ ", hint = " " },
      },
    },
    lualine_y = {
      {
        "encoding",
        fmt = string.upper,
      },
      "filetype",
    },
    lualine_z = {
      "location",
      "progress",
    },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  extensions = { "quickfix", "fugitive", "nvim-tree" },
}
