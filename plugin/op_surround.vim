vim9script

# An operator-friendly surround plugin
# Maintainer:	Ubaldo Tiberi
# License: BSD3-Clause.

if !has('vim9script') ||  v:version < 900
  # Needs Vim version 9.0 and above
  echo "You need at least Vim 9.0"
  finish
endif

g:op_surround_loaded = false

import autoload "./../autoload/funcs.vim" as funcs

if exists('g:op_surround_maps')
    && type(g:op_surround_maps) != v:t_list
  funcs.Echoerr("'g:op_surround_maps' shall be a list of dict")
  finish
endif

if exists('g:op_surround_maps')
  for item in g:op_surround_maps
    if empty(maparg(item.map, 'n'))
      exe $"nnoremap {item.map} <ScriptCmd>funcs.SetSurroundOpFunc("
        .. $" '{item.open_delim}', '{item.close_delim}', '{item.action}')<cr>g@"
    endif
    if empty(maparg(item.map, 'x'))
      exe $"xnoremap {item.map} <ScriptCmd>funcs.SetSurroundOpFunc("
        .. $" '{item.open_delim}', '{item.close_delim}', '{item.action}')<cr>g@"
    endif
  endfor
endif

def OpSurroundMakeMappings()
  if exists('g:op_surround_maps')
    for item in g:op_surround_maps
      if empty(maparg(item.map, 'n'))
        exe $"nnoremap {item.map} <ScriptCmd>funcs.SetSurroundOpFunc("
          .. $" '{item.open_delim}', '{item.close_delim}', '{item.action}')<cr>g@"
      endif
      if empty(maparg(item.map, 'v'))
        exe $"xnoremap {item.map} <ScriptCmd>funcs.SetSurroundOpFunc("
          .. $" '{item.open_delim}', '{item.close_delim}', '{item.action}')<cr>g@"
      endif
    endfor
  endif

  if exists('b:op_surround_maps')
    for item in b:op_surround_maps
      if !maparg(item.map, 'n', 0, 1)->get('buffer', false)
        exe $"nnoremap <buffer> {item.map} <ScriptCmd>funcs.SetSurroundOpFunc("
          .. $" '{item.open_delim}', '{item.close_delim}', '{item.action}')<cr>g@"
      endif
      if !maparg(item.map, 'v', 0, 1)->get('buffer', false)
        exe $"xnoremap <buffer> {item.map} <ScriptCmd>funcs.SetSurroundOpFunc("
          .. $" '{item.open_delim}', '{item.close_delim}', '{item.action}')<cr>g@"
      endif
    endfor
  endif
enddef

OpSurroundMakeMappings()
command! -nargs=0 OpSurroundMakeMappings OpSurroundMakeMappings()
