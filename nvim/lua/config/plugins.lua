-- neovim plugins managed by lazy.nvim
-- Plugins specs are located at: ~/.config/nvim/lua/plugins/

local M = {}

local PLUGIN_SPEC = {
  { import = "plugins.basic" },
  { import = "plugins.appearance" },
  { import = "plugins.ui" },
  { import = "plugins.keymap" },
  { import = "plugins.git" },
  { import = "plugins.ide" },
  { import = "plugins.treesitter" },
  { import = "plugins.utilities" },
}

-- $VIMPLUG
-- vim.env.VIMPLUG = vim.fn.stdpath("data") .. "/lazy"
vim.env.VIMPLUG = vim.fn.expand('$HOME/.vim/plugged')

-- Bootstrap lazy.nvim plugin manager
-- https://github.com/folke/lazy.nvim
local lazypath = vim.env.VIMPLUG .. "/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Setup and load plugins. All plugins will be source HERE!
-- https://github.com/folke/lazy.nvim#%EF%B8%8F-configuration
-- @see $VIMPLUG/lazy.nvim/lua/lazy/core/config.lua
require("lazy").setup(PLUGIN_SPEC, {
  root = vim.env.VIMPLUG,
  defaults = {
    -- Plugins will be loaded as soon as lazy.setup()
    lazy = false,
  },
  install = {
    missing = true,
    colorscheme = {"xoria256-wook"},
  },
  ui = {
    wrap = true,
    border = 'double',
    icons = {  -- Nerd-font v3 (https://www.nerdfonts.com/cheat-sheet)
      func = "󰊕",
      list = { "●", "➜", "", "-" },
    }
  },
  performance = {
    rtp = {
      paths = {
        '~/.vim',  -- Allows ~/.vim/colors, etc. accessible
      },
      disabled_plugins = {
        "netrwPlugin",
      },
    },
  },
  change_detection = {
    notify = true,
  },
})

-- Close auto-install window
vim.cmd [[
  if &filetype == 'lazy' | q | endif
]]

-- Add rplugins support on startup; see utils/plug_utils.lua
require("utils.plug_utils").UpdateRemotePlugins()

-- Disable lazy clean by monkey-patching. (see #762)
require("lazy.manage").clean = function(opts)
  print("[lazy.nvim] Clean operation is disabled.")
  return require("lazy.manage").run({ pipeline = {} })
end

-- Additional lazy-load events: 'func' (until it's officially supported)
local Lazy_FuncUndefined = vim.api.nvim_create_augroup('Lazy_FuncUndefined', { clear = true })
vim.tbl_map(function(p)   ---@type LazyPluginSpec
  if p.lazy and p.func then
    vim.api.nvim_create_autocmd('FuncUndefined', {
      pattern = p.func,
      group = Lazy_FuncUndefined,
      once = true,
      callback = function(ev)
        -- the actual function that was required and triggered the plugin.
        local reason = { func = ev.match }
        require("lazy.core.loader").load(p.name, reason, { force = true })
      end,
      desc = string.format("Lazy plugin: %s, func: %s", p.name, (function()
        if type(p.func) == 'string' then return p.func
        else return "{ " .. table.concat(p.func, ", ") .. " }"
        end
      end)()),
    })
  end
end, require("lazy").plugins())


-- remap keymaps and configure lazy window
require("lazy.view.config").keys.profile_filter = "<C-g>"
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lazy",
  callback = function(args)
    local buf = args.buf
    vim.defer_fn(function()
      -- Ctrl+C: to quit the window (only if it's floating)
      vim.keymap.set("n", "<C-c>", function()
        local is_float = vim.api.nvim_win_get_config(0).relative ~= ""
        return is_float and "q" or ""
      end, { buffer = true, remap = true, expr = true })

      -- Highlights
      vim.cmd [[
        hi! LazyProp guibg=NONE
        hi def link LazyReasonFunc  Function
      ]]

      -- make goto-file (gf, ]f) work, but open in a new tab
      vim.opt_local.path:append(vim.env.VIMPLUG)
      vim.keymap.set('n', 'gf', '<cmd>wincmd gf<CR>', { remap = false, buffer = true })
      vim.keymap.set('n', ']f', 'gf', { remap = true, buffer = true })

      -- folding support
      vim.cmd [[ setlocal sw=2 foldmethod=expr foldexpr=v:lua.lazy_foldexpr() ]]
      pcall(function()
        -- UFO somehow doesn't get attached automatically, so manually enable folding
        require("ufo").attach(buf)
      end)
    end, 0)
  end,
})

-- foldexpr for Lazy
function _G.lazy_foldexpr(lnum)
  lnum = lnum or vim.v.lnum
  local l = vim.fn.getline(lnum)
  if l:match("^%s*$") then
    return 0
  end
  local indent_next = vim.fn.indent(lnum + 1)
  local indent_this = vim.fn.indent(lnum)
  local sw = 2  -- tab size
  if indent_next < indent_this then
    return '<' .. (indent_this / sw - 1)
  elseif indent_next > indent_this then
    return '>' .. (indent_next / sw - 1)
  else
    return indent_this / sw - 1
  end
end

-- :Plugs -- quickly locate and find plugin defs
-- TODO: Use lazy API to retrieve full plugin spec instead of grep.
vim.api.nvim_create_user_command('Plugs', function(opts)
  local entry_maker = require('telescope.make_entry').gen_from_vimgrep({ })
  require('telescope.builtin').grep_string({
    search_dirs = { '~/.config/nvim/lua/plugins' },
    only_sort_text = true,
    use_regex = true,
    search = 'Plug \'.+\'',
    default_text = opts.args,
    entry_maker = function(line)
      local e = entry_maker(line)
      e.ordinal = e.text
      e.display = function()
        local plug_id = e.text:match([['(.-)']])  -- extract string within '' (shorturl)
        local display = plug_id .. ('   ') .. string.format('[%s]', e.filename:match(".+/(.*)$") )
        return display, {
          { {plug_id:find('/'), #plug_id}, 'Identifier' },
          { {#plug_id + 1, #display}, 'Comment' },
        }
      end
      e.col = e.col + 6  -- a hack to make the jump location (column) located in the shorturl
      return e
    end,
    layout_config = {
      preview_cutoff = 80,
      preview_width = 0.5,
    },
  })
end, { nargs = '?', desc = 'Plugs: find lazy plugin declaration.',
complete = function()
  local names = M.list_plugs(); table.sort(names); return names
end})

-- list_plugs: Get all the registered plugins (including non-loaded ones)
---@return string[]
function M.list_plugs()
  return vim.tbl_keys(require("lazy.core.config").plugins)
end

-- load: immediately load (lazy) plugins synchronously
---@return LazyPlugin?
function M.load(names)
  require("lazy.core.loader").load(names, {}, { force = true })
end

return M
