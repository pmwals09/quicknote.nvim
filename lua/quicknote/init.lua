local M = {}
local config = {}

--- @class FloatPositionOptions
--- @field row integer
--- @field col integer
--- @field height integer
--- @field width integer
--- @field relative "editor"

--- Calculate size and position options for the floating window.
--- @return FloatPositionOptions
local function get_win_options()
  local width = vim.api.nvim_get_option("columns")
  local height = vim.api.nvim_get_option("lines")

  local float_width = math.ceil(width * 0.8) - 10
  local float_height = math.ceil(height * 0.8) - 10

  local col = math.ceil((width - float_width) / 2)
  local row = math.ceil((height - float_height) / 2)

  return {
    row = row,
    col = col,
    height = float_height,
    width = float_width,
    relative = "editor",
  }
end

--- @class Options
--- @field notes_dir string
--- @field page_header string | function(): string
--- @field note_header string | function(): string
--- @field file_name string | function(): string

--- @type Options
local DEFAULT_CONFIG = {
  notes_dir = "~/notes",
  file_name = function()
    local date = os.date("%Y-%m-%d", os.time())
    return "note-" .. date .. ".md"
  end,
  page_header = function()
    local date = os.date("%Y-%m-%d", os.time())
    return "# Notes for " .. date
  end,
  note_header = function()
    return "## " .. os.date("%H:%M", os.time())
  end,
}

--- Checks for whether a file exists or not, to differentiate from other error types.
--- @param path string
--- @return boolean
local function file_does_exist(path)
  local fh, msg = io.open(path, "r")
  if msg ~= nil then
    local start = msg:find("No such file")
    if start == nil then
      vim.notify("Problem reading notes file", vim.log.levels.ERROR)
      return true
    end
    if fh ~= nil then
      fh:close()
    end
    return false
  end
  return true
end

--- Extracting a string value from a key whose value is either a string, or a 
--- function that returns a string
--- @param opts Options
--- @param key string
--- @return string | nil
local function get_string_or_fn_opt(opts, key)
  local val = opts[key]
  if type(val) == "string" then return val end
  if type(val) == "function" then return val() end
  return nil
end

--- Runs the plugin
--- @param opts Options
M.run = function(opts)
  local bh = vim.api.nvim_create_buf(false, false)
  if bh == 0 then
    vim.notify("Problem creating note buffer", vim.log.levels.ERROR)
    return
  end

  vim.bo[bh].modifiable = true

  local wh = vim.api.nvim_open_win(bh, true, get_win_options())
  if wh == 0 then
    vim.notify("Problem opening the note-taking window", vim.log.levels.ERROR)
    return
  end

  local file_name = get_string_or_fn_opt(opts, "file_name")
  if file_name == nil then
    local date = os.date("%Y-%m-%d", os.time())
    file_name = "note-" .. date .. ".md"
  end
  --- @type string
  local file_path = config.notes_dir .. "/" .. file_name

  local fp = file_path:gsub("~", vim.env.HOME)

  local file_exists = file_does_exist(fp)
  local fh = io.open(fp, "a")
  if fh == nil then
    vim.notify("Problem appending to today's notes file", vim.log.levels.ERROR)
    return
  end

  if not file_exists then
    local page_header_text = get_string_or_fn_opt(opts, "page_header")
    if page_header_text == nil then
      page_header_text = "# Notes"
    end
    fh:write(page_header_text)
    fh:close()
  end

  vim.cmd.edit(fp)

  vim.cmd.norm("Go")

  local note_header_text = get_string_or_fn_opt(opts, "note_header")
  if note_header_text == nil then
    note_header_text = "## New note"
  end

  vim.cmd.norm("Go" .. note_header_text)
  vim.cmd.norm("G2o")
  vim.cmd.norm("zz")
  vim.cmd.startinsert()
end

M.setup = function(opts)
  config = vim.tbl_deep_extend("force", config, DEFAULT_CONFIG, opts or {})
  vim.api.nvim_create_user_command("Quicknote", function()
    M.run(config)
  end, { desc = "Open up a daily note for tracking your thoughts on the fly", force = true })
end

return M
