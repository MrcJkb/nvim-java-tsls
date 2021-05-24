local M = {}

-- Gets the line content for the current buffer
--@param line number
--@return (string)
M.current_buf_get_line_content = function(line)
  local lines = vim.api.nvim_buf_get_lines(0, line, line + 1, false)
  if not line then return nil end
  return lines[1]
end

-- Checks the current buffer for a public keyword
--@param line number
--@return (boolean)
M.current_buf_contains_public_keyword = function(line)
  local line_content = M.current_buf_get_line_content(line)
  if not line_content then return false end
  return string.find(line_content, ' public ')
end

M.set_register = function(contents)
  local output
  vim.api.nvim_exec([[call setreg("0", "]] .. contents .. [[", "l")]], output)
  if output then
    print('Unable to set register: ' .. vim.inspect(output))
  end
end

return M

