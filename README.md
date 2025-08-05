# vim-op-surround

A simple Vim9 surround plugin!

The usage follows Vim idioms, adhering to the `<your_map>{motion}` pattern.
For example, `sa"iw` surrounds the word under the cursor with double quotes,
and `sa(fa` surrounds the text from the cursor to the next a with parentheses—
assuming you’ve defined such mappings (see below). It also works in visual
mode and it supports multi-byte characters.

# Requirements

Vim 9.1 is required.

# Usage

You must define your mappings using the `g:op_surround_maps` variable. This
variable should be a dictionary of dictionaries, where each top-level key is a
unique identifier for a specific surround mapping.

Each mapping dictionary must include the following keys:

- `map`: the key sequence that triggers the surround operation
- `open_delim`: the opening delimiter to insert
- `close_delim`: the closing delimiter to insert
- `action`: can be `'append'` or `'delete'`.

### Example

```vim
# Set typical surroundings such as parenthesis, brackets, quotes, ...
g:op_surround_maps = []
for [open, close] in [("(", ")"), ("[", "]"), ("{", "}"),
    ('"', '"'), ("''", "''")]
  # Append mappings
  add(g:op_surround_maps, {
    map: $"sa{open}",
    open_delim: open,
    close_delim: close,
    action: 'append'})

  # Delete mappings
  add(g:op_surround_maps, {
    map: $"sd{open}",
    open_delim: open,
    close_delim: close,
    action: 'delete'})
endfor
```

In the same way, you can define buffer-local surrounding maps through the
dictionary `b:op_surround_maps` followed by the command
`:OpSurroundMakeMappings` to actually set the mappings.

## License

BSD-3.

<!-- DO NOT REMOVE vim-markdown-extras references DO NOT REMOVE-->
