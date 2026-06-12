# LazyBacklog

Neovim plugin for [backlog](https://github.com/hantsaniala/backlog) -- a terminal UI for `.backlog/` project management files.

Opens the backlog TUI in a floating terminal window inside Neovim. Works with LazyVim and other plugin managers.

## Features

- Opens backlog in a floating or split terminal window
- Auto-detects `.backlog/` directory by walking up from CWD
- Passes `$NVIM` env so backlog knows it's inside Neovim
- Opens task files in Neovim on `o` press inside backlog
- Toggle behavior -- same key opens and closes
- Configurable position, size, and binary path

## Requirements

- [backlog](https://github.com/hantsaniala/backlog) binary on `$PATH`
- Neovim >= 0.9.0

Install backlog:

```sh
go install github.com/hantsaniala/backlog@latest
```

## Installation

### LazyVim

```lua
{
  "hantsaniala/lazybacklog.nvim",
  opts = {
    key = "<leader>lb",
    position = "float",
  },
}
```

### lazy.nvim

```lua
{
  "hantsaniala/lazybacklog.nvim",
  opts = {},
}
```

### packer.nvim

```lua
use {
  "hantsaniala/lazybacklog.nvim",
  config = function()
    require("lazybacklog").setup({})
  end,
}
```

## Commands

| Command | Description |
|---------|-------------|
| `:LazyBacklog` | Toggle LazyBacklog window |
| `:LazyBacklogOpen` | Open LazyBacklog window |
| `:LazyBacklogClose` | Close LazyBacklog window |

## Keybindings

| Key | Mode | Action |
|-----|------|--------|
| `<leader>lb` | Normal | Toggle LazyBacklog |
| `Esc` | Terminal | Exit terminal mode |
| `q` | Terminal | Close LazyBacklog and return to Neovim |

The default keybinding `<leader>lb` is a two-key sequence: `<leader>` then `l` then `b`. It does not conflict with any default LazyVim or Neovim bindings.

## Configuration

```lua
require("lazybacklog").setup({
  -- Keybinding to toggle LazyBacklog (false to disable)
  key = "<leader>lb",

  -- Window position: "float" | "right" | "bottom" | "left"
  position = "float",

  -- Floating window size (fraction of editor dimensions)
  width = 0.85,
  height = 0.85,

  -- Split window size (columns for left/right, lines for top/bottom)
  split_size = 40,

  -- Path to backlog binary (default: search PATH)
  binary = "backlog",

  -- Extra arguments passed to backlog (e.g., { "--wait" })
  extra_args = {},
})
```

## How it works

1. When you press `<leader>lb` or run `:LazyBacklog`, the plugin walks up from your current working directory looking for a `.backlog/` directory.
2. It opens a terminal window running `backlog --path <root> --editor "nvim --remote-send"`.
3. The backlog binary detects `$NVIM` and knows it is running inside Neovim.
4. When you press `o` on a task in backlog's detail view, it opens the task file (`tasks/<ID>.md`) in Neovim.
5. Press `q` inside backlog to quit; the terminal window closes automatically when backlog exits.
6. To exit terminal mode (e.g. to use Neovim windows), press `<C-\><C-n>` — standard Neovim terminal method.

## Development

```sh
git clone https://github.com/hantsaniala/lazybacklog.nvim
cd lazybacklog.nvim
# Use with a local dev-override in your Neovim config:
-- { dir = "~/path/to/lazybacklog.nvim", opts = {} }
```

## License

MIT
