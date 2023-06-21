vim.cmd [[ setlocal ts=2 sts=2 sw=2 ]]

-- Workaround for neovim#20456: vim syntax for lua files are broken in neovim 0.8+
if pcall(require, 'nvim-treesitter') then
  -- Disable the erroneous $VIMRUNTIME/syntax/lua.vim from loading
  vim.b.ts_highlight = 1

  -- Use treesitter highlight for vimscripts. (nvim 0.8+)
  vim.treesitter.start()
end
