-- Basic and essential plugins.

local Plug = require('utils.plug_utils').Plug

return {
  Plug 'nvim-lua/plenary.nvim' { priority = 10000 };
  Plug 'rcarriga/nvim-notify' { config = require 'config.ui'.setup_notify };

  Plug 'tweekmonster/helpful.vim' {
    cmd = 'HelpfulVersion',
  };
  Plug 'dstein64/vim-startuptime' {
    cmd = 'StartupTime',
  };

  Plug 'embear/vim-localvimrc';
}
