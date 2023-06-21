-- Keymap related plugins (cmds, etc.)

local Plug = require('utils.plug_utils').Plug
local PlugConfig = require('utils.plug_utils').PlugConfig

return {
  -- Keymaps
  Plug 'junegunn/vim-peekaboo' { event = 'UIEnter' };
  Plug 'folke/which-key.nvim' { init = PlugConfig, event = 'UIEnter' };

  -- Actions and operators
  Plug 'Lokaltog/vim-easymotion' { keys = '<leader>f' };
  Plug 'junegunn/vim-easy-align' {
    keys = { '<Plug>(EasyAlign)', { '<Plug>(EasyAlign)', mode = 'v' } },
  };
  Plug 'tpope/vim-surround' { event = 'UIEnter' };
  Plug 'tpope/vim-repeat' { lazy = true, func = 'repeat#*' };
  Plug 'haya14busa/vim-asterisk' { init = PlugConfig, event = 'UIEnter' };
  Plug 'haya14busa/incsearch-fuzzy.vim' {
    event = 'UIEnter',
    dependencies = {
      Plug 'haya14busa/incsearch.vim' { init = PlugConfig, event = 'UIEnter' };
    },
  };
  Plug 'unblevable/quick-scope' {
    keys = { 'f', 'F', 't', 'T'}
  };
  Plug 't9md/vim-quickhl' {
    keys = { '<leader>*', '<leader>8' },
  };

  -- Undo
  Plug 'sjl/gundo.vim' { enabled = false };  -- TODO: Use mundo
  Plug 'machakann/vim-highlightedundo' {
    cond = vim.fn.executable('diff') > 0,
    init = PlugConfig,
    keys = {
      '<Plug>(highlightedundo-undo)', '<Plug>(highlightedundo-redo)', '<Plug>(highlightedundo-Undo)',
      '<Plug>(highlightedundo-gminus)', '<Plug>(highlightedundo-gplus)'
    },
  };
}
