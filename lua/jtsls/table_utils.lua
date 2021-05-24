local M = {}

-- Filters a table by a predicate
--@param predicate (function) a predicate function for filtering the table's items
--@param t (table) The table
--@return (table) a table containing elements that match the predicate
M.filter_table = function(predicate, t)
  local res = {}
  for _, item in ipairs(t) do
    -- print('item: ' .. vim.inspect(item))
    if predicate(item) then
      table.insert(res, item)
    end
  end
  return res
end

return M
