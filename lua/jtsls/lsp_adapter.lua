local util = require 'vim.lsp.util'

local M = {}

--- Makes a synchronous request for the current buffer
--- See vim.lsp.buf_request_synv
--@param method (string) the LSP method
--@param (table) the LSP request parameters
--@return a result string, or nil if no result was received
local function request_for_current_buffer_sync (method, params)
  return vim.lsp.buf_request_sync(0, method, params)
end

--- Gets document symbols for the current buffer
--@return (table) a JSON result string from the language server, or nil if no result was received
local function get_document_symbols_current_buffer()
  local params = { textDocument = util.make_text_document_params() }
  return request_for_current_buffer_sync('textDocument/documentSymbol', params)
end

M.get_document_symbols = function()
  local doc_symbol_wrapper = get_document_symbols_current_buffer();
  if not doc_symbol_wrapper
    or vim.tbl_isempty(doc_symbol_wrapper)
    or not doc_symbol_wrapper[1].result
  then
    print('No document symbols found.')
    return nil
  end
  return doc_symbol_wrapper[1].result
end

return M
