# vim-op-surround

Yet another surround plugin.

Differently from existing plugins, the motion here is applied to the end of
the mappings, i.e. `<your_map>{motion}`.
You can also define buffer-local mappings.
Repeat works out-of-the-box.

# Requirements

Vim 9.0 is required.

# Usage

You have to define mappings through the variable `g:op_surround_maps`. Such a
variable is a list of dicts, where the dictionaries keys are `map`,
`open_delim` and `close_delim`.

Example:

```
  g:op_surround_maps = [{map: "<leader>(", open_delim: "(", close_delim: ")"},
    {map: "<leader>[", open_delim: "[", close_delim: "]"},
    {map: "<leader>{", open_delim: "{", close_delim: "}"},
    {map: '<leader>"', open_delim: '"', close_delim: '"'},
    {map: "<leader>'", open_delim: "''", close_delim: "''"}
  ]
```

and use `<leader>(iw, <leader>[fa`, etc.
It also works in visual mode.

Along the same line, you can define buffer-local mappings through the variable
`b:op_surround_maps`. This is handy in case you want different mappings for
different filetypes.
Once you have defined `b:op_surround_maps`, you must run the
`:OpSurroundMakeBufferMap` command to create the buffer-local mappings.
