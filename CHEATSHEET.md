# Cheatsheet

## Terminal

### Navigation & Editing (Insert Mode)
These shortcuts allow for "Emacs-style" navigation even while running Zsh in Vi-mode.

| Keybinding | Action | Source |
| :--- | :--- | :--- |
| **`Ctrl` + `a`** | Jump to **Start** of line | `zsh/zsh.d/key-bindings.zsh` |
| **`Ctrl` + `e`** | Jump to **End** of line | `zsh/zsh.d/key-bindings.zsh` |
| **`Ctrl` + `f`** | Move **Forward** one word | `zsh/zsh.d/key-bindings.zsh` |
| **`Ctrl` + `b`** | Move **Backward** one word | `zsh/zsh.d/key-bindings.zsh` |
| **`Alt` + `.`** | Insert the **Last Argument** from the previous command | `zsh/zsh.d/key-bindings.zsh` |
| **`Ctrl` + `x`, `Ctrl` + `e`** | Open current command line in **$EDITOR** (Neovim) | `zsh/zsh.d/key-bindings.zsh` |

### History & Search (Powered by FZF)
| Keybinding | Action | Source |
| :--- | :--- | :--- |
| **`Ctrl` + `r`** | **Fuzzy Search** command history (Interactive) | `zsh/zsh.d/envs.zsh` |
| **`Ctrl` + `p`** | Previous command (Up in history) | `zsh/zsh.d/key-bindings.zsh` |
| **`Ctrl` + `n`** | Next command (Down in history) | `zsh/zsh.d/key-bindings.zsh` |
| **`Ctrl` + `Space`** | **Fuzzy Find Files** (Insert filename into command) | `zsh/zsh.d/fzf-widgets.zsh` |
