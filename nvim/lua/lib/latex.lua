-- lib.latex
-- LaTeX language support

local M = {}

---Returns true if the cursor is currently located in a mathzone, implemented by treesitter.
---Ref: https://github.com/nvim-treesitter/nvim-treesitter/issues/1184
---@return boolean
function M.in_mathzone()
  -- Get the treesitter node (offsets col position when in insert mode)
  -- When treesitter parse is not available, don't throw errors but simply return false.
  ---@type TSNode?
  local node = vim.F.npcall(require("utils.ts_utils").get_node_at_cursor)

  while node do
    if node:type() == 'text_mode' then
      return false
    elseif vim.tbl_contains({ 'displayed_equation', 'inline_formula', 'math_environment' }, node:type()) then
      return true
    end
    node = node:parent()
  end
  return false
end

return M
