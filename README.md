# vim-op-surround

Quick & dirty surround plugin.

Differently from existing plugins, the motion here is applied to the end of
the mappings, i.e. `<your_map>{motion}`.
You can also define buffer-local mappings.
Repeat works out-of-the-box.

# Requirements

Vim 9.1 is required.

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
The (behavior) is "toggle" in the sense that if you repeat the same command
twice it will add and remove the delimiters. For example, go on a word and type
`<leader>(iw` to add parenthesis. Then, go again on the same work and type
again `<leader>(iw`. The parenthesis are gone.
It also works in visual mode.

Along the same line, you can define buffer-local mappings through the variable
`b:op_surround_maps`. This is handy in case you want different mappings for
different filetypes.
Once you have defined `b:op_surround_maps`, you must run the
`:OpSurroundMakeMap` command to create the buffer-local mappings.
