# Quicknote

This plugin opens a file in a floating window for quick note-taking while in the middle of another task.
Inspired by [this video](https://www.youtube.com/watch?v=zB_3FIGRWRU&t=364s&ab_channel=CalinLeafshade-Linux%26ProductivityVideos), but I don't have a Linux machine and I don't use i3, so I decided to implement something like it in NeoVim.

## Installation

### Using Lazy

```lua
{
    'pmwals09/quicknote.nvim'
}
```

## Configuration/Setup

You can set up Quicknote by running the following:

```lua
require('quicknote').setup({})
```

The default configuration has been copied below, along with the available configuration values and types that can be used to customize your config.

```lua
require('quicknote').setup({
    notes_dir = "~/notes",
    file_name = function()
      local date = os.date("%Y-%m-%d", os.time())
      return "note-" .. date .. ".md"
    end,
    page_header = function()
      local date = os.date("%Y-%m-%d", os.time())
      return "# Notes for " .. date
    end,
    note_header = function()
      return "## " .. os.date("%H:%M", os.time())
    end,
})
```

- `Options.nodes_dir: string`: the directory path where new notes will be saved.
- `Options.file_name: string | function(): string`: a string, or a function that returns a string, of the name of new files. If this is a static string, then Quicknote will only open and append to a single file (i.e., a TODO file or a running NOTES file).
- `Options.page_header: string | function(): string`: a string, or a function that returns a string, that is used as the first line of the new file where a standard H1 in an MD file would go.
- `Options.note_header: string | function(): string`: a string, or a function that returns a string, that is added to the file before each note entry.
