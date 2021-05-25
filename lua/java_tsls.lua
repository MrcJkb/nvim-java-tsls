local lsp_adapter = require'jtsls.lsp_adapter'
local nvim_client = require'jtsls.nvim_client'
local table_utils = require'jtsls.table_utils'

local CLASS_KIND = 5
local METHOD_KIND = 6

local M = {}

-- Gets the root class name (i.e. the name of the class which has the same name as the file name).
--@param document_symbols (table) The LSP document symbols
--@return (string) the name of the root class
local function get_root_class_name(document_symbols)
  local class_name_predicate = function(document_symbol)
    -- print(vim.inspect(document_symbol))
    return document_symbol.kind == CLASS_KIND
  end
  local class_table = table_utils.filter_table(class_name_predicate, document_symbols)
  if not class_table or vim.tbl_isempty(class_table) then
    print("No class document symbol found.")
    return nil
  end
  local class_document_symbol = class_table[1]
  return class_document_symbol.name
end

-- Checks the current buffer for a public keyword
--@param line number
--@return (boolean)
local function current_buf_contains_public_keyword(line)
  local line_content = nvim_client.current_buf_get_line_content(line)
  if not line_content then return false end
  return string.find(line_content, ' public ')
end

-- Retrieves the method definition (without its body).
--@param (table) an LSP method document symbol
--@return (string)
local function get_method_definition(method_symbol)
  local line = method_symbol.range.start.line
  local line_content = nvim_client.current_buf_get_line_content(line)
  line_content = string.gsub(line_content, ' public ', '')
  line_content = string.gsub(line_content, '{', ';')
  return string.gsub(line_content, '[ \t];', '')
end

-- Gets the public method definitions of a class.
--@param document_symbols (table) The LSP document symbols
--@param class_name (string) the name of the class to filter for
--@return (table) the class's public methods
local function get_public_method_definitions(document_symbols, class_name)
  local res = {}
  local public_method_predicate = function(document_symbol)
    print(vim.inspect(document_symbol))
    return document_symbol.kind == METHOD_KIND
      and document_symbol.containerName == class_name
      and document_symbol.range
      and current_buf_contains_public_keyword(document_symbol.range.start.line)
  end
  local public_methods_table = table_utils.filter_table(public_method_predicate, document_symbols)
  if not public_methods_table or vim.tbl_isempty(public_methods_table) then
    print("No public methods found.")
    return res
  end
  for _, item in ipairs(public_methods_table) do
    local method_definition = get_method_definition(item)
    table.insert(res, method_definition)
  end
  return res
end

M.yank_public_method_definitions = function()
  local document_symbols = lsp_adapter.get_document_symbols()
  if not document_symbols then return nil end
  local class_name = get_root_class_name(document_symbols)
  if not class_name then return nil end
  local public_method_names = get_public_method_definitions(document_symbols, class_name)
  local method_definitions = ''
  for _, method_name in ipairs(public_method_names) do
    method_definitions = method_definitions .. '  ' .. method_name .. ';\\n\\n'
  end
  nvim_client.set_register(method_definitions)
end

M.yank_java_interface = function()
  local document_symbols = lsp_adapter.get_document_symbols()
  if not document_symbols then return nil end
  local class_name = get_root_class_name(document_symbols)
  if not class_name then return nil end
  -- print(vim.inspect(class_name))
  local public_method_names = get_public_method_definitions(document_symbols, class_name)
  -- print(vim.inspect(public_method_names))
  local interface_definition = 'interface I' .. class_name .. ' {\\n\\n'
  for _, method_name in ipairs(public_method_names) do
    interface_definition = interface_definition .. method_name .. ';\\n\\n'
  end
  interface_definition = interface_definition .. '}'
  -- print(interface_definition)
  nvim_client.set_register(interface_definition)
  return interface_definition
end

-- Sets up Ex commands for LSP powered features.
M.setup_lsp_commands = function()
 vim.cmd[[
  command! -nargs=0 JYankInterface :lua require('java_tsls').yank_java_interface()
  command! -nargs=0 JYankPublicMethods :lua require('java_tsls').yank_public_method_definitions()
 ]]
end

return M

-- TODO get_java_interface_current_class --> check range at cursor position, in case of more than one interface in the same file
