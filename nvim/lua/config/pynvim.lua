--- config/pynvim
---@return fun(): boolean
-- Set the g:python3_host_prog variable to path to python3 in $PATH.
-- pynvim package will be automatically installed if it was missing.

vim.g.python3_host_prog = ''

-- for future has('python3') like use
local OK_PYNVIM = function() return true end
local NO_PYNVIM = function() return false end

-- Utility: Run a shell command and capture the output.
local function system(command)
  local file = assert(io.popen(command, 'r'))
  local output = file:read('*all'):gsub("%s+", "")
  file:close()
  return output
end

-- Utility: echomsg with optional highlight.
local function echom(msg, hlgroup)
  -- TODO: neovim does not retain highlight unlike :echom does, see neovim#13812
  -- vim.api.nvim_echo({{ msg, hlgroup }}, true, {})
  hlgroup = hlgroup or 'Normal'
  msg = vim.fn.escape(msg, '"')
  local cmd = [[echohl $hlgroup | echomsg "$msg" | echohl None]]
  cmd = cmd:gsub('%$(%w+)', { msg = msg, hlgroup = hlgroup })
  vim.cmd(cmd)
end
local function warning(msg)
  return echom(msg, 'WarningMsg')
end
local function notify_later(msg, level)
  level = level or vim.log.levels.WARN
  vim.schedule(function()
    vim.notify(msg, level, {title = '~/.config/nvim/lua/config/pynvim.lua', timeout = 10000})
  end)
end

-- Use python3 as per $PATH as the host python for neovim.
if vim.fn.executable("python3") > 0 then
  vim.g.python3_host_prog = vim.fn.exepath("python3")
else
  warning "ERROR: You don't have python3 on your $PATH. Check $PATH or $SHELL. Most features are disabled."
  return NO_PYNVIM
end

-- Now that g:python3_host_prog is set, we can call has('python3')
if vim.fn.has('python3') == 0 then
  vim.schedule(function()
    vim.notify('WARNING: This version of neovim is unsupported, lacking +python3.\n',
      vim.log.levels.WARN, { title = 'config/pynvim' })
  end)
  return OK_PYNVIM
end

local function determine_pip_options()
  local pip_option = ""
  local has_mac = vim.fn.has('mac') > 0
  if has_mac then
    -- Use '--user' option when needed
    local py_prefix = system("python3 -c 'import sys; print(sys.prefix)' 2>/dev/null")
    if py_prefix == "/usr" or py_prefix == "/usr/local" then
      pip_option = "--user"
    end
    pip_option = pip_option .. " --upgrade --ignore-installed"

    -- mac: Force greenlet to be compiled from source due to potential architecture mismatch (pynvim#473)
    if has_mac then
      pip_option = pip_option .. ' --no-binary greenlet'
    end
    return pip_option
  end
  return pip_option
end
local function autoinstall_pynvim()
  -- Require pynvim >= 0.4.0
  local python3_neovim_version = system(vim.g.python3_host_prog .. " -c 'import pynvim; print(pynvim.VERSION.minor)' 2>/dev/null")
  if tonumber(python3_neovim_version) == nil or tonumber(python3_neovim_version) < 4 then
    echom("Automatically installing pynvim into python environment: " .. vim.g.python3_host_prog, "MoreMsg")
    local pip_install_cmd = (
      vim.g.python3_host_prog .. " -m ensurepip; " ..
      vim.g.python3_host_prog .. " -m pip install " .. determine_pip_options() .. " pynvim"
    )
    vim.api.nvim_command("!" .. pip_install_cmd)
    if vim.v.shell_error == 0 then
      echom("Successfully installed pynvim. Please restart neovim.", "MoreMsg")
      notify_later("Successfully installed pynvim. Please restart neovim.", "info")
    else
      notify_later('g:python3_host_prog = ' .. vim.g.python3_host_prog)
      notify_later('Installing pynvim failed (try :Notifications) \n' .. pip_install_cmd)
      warning("Installation of pynvim has failed. Python-based features may not work.")
      return false
    end
  end
  return true
end

-- python version check
local function python3_version_check()
  if vim.fn.py3eval('sys.version_info < (3, 6)') then
    local py_version = vim.fn.py3eval('".".join(str(x) for x in sys.version_info[:3])')
    if py_version == 0 then py_version = "cannot read" end
    local msg = string.format("Your python3 version (%s) is too old; ", py_version)
    warning(msg)
    msg = msg .. '\n' .. "python 3.6+ is required. Most features are disabled."
    msg = msg .. '\n\n' .. "g:python3_host_prog = " .. vim.g.python3_host_prog
    notify_later(msg)
    return false
  end
  return true
end

-- Make a dummy call first, to workaround a bug neovim#14438
-- NOTE: This takes some time, but is necessary otherwise other python plugins will fail
vim.fn.py3eval("1")

if vim.fn.py3eval("1") ~= 1 then
  -- pynvim is missing, try installing it
  local ret = autoinstall_pynvim()
  if not ret then return NO_PYNVIM end
else
  -- pynvim already there, check versions lazily
  vim.schedule(function()
    autoinstall_pynvim()
    python3_version_check()
  end)
end

-- Return true iff python3 is available.
-- Instead of calling has('python3'), use require('config.pynvim').
return OK_PYNVIM
