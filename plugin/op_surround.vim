vim9script

# An operator-friendly surround plugin
# Maintainer:	Ubaldo Tiberi
# License: BSD3-Clause.

if !has('vim9script') ||  v:version < 900
  # Needs Vim version 9.0 and above
  echo "You need at least Vim 9.0"
  finish
endif

if exists('g:op_surround_loaded')
  finish
endif
g:op_surround_loaded = true

if exists('g:op_surround_maps')
    && type(g:op_surround_maps) != v:t_list
  echoerr "[vim-op-surround] 'g:op_surround_maps' shall be a list of dict"
  finish
endif

def Surround(open_delim: string, close_delim: string, type: string = '')

  if getcharpos("'[") == getcharpos("']")
    return
  endif

  # line and column of point A
  var lA = line("'[")
  var cA = type == 'line' ? 1 : col("'[")

  # line and column of point B
  var lB = line("']")
  var cB = type == 'line' ? len(getline(lB)) : col("']")

  var save_cursor = getcurpos()

  # TODO: include/exclude
  var A = strcharpart(getline(lA), cA - len(open_delim) - 1, len(open_delim))
  var B = strcharpart(getline(lB), cB, len(close_delim))
  var offset = 0

  cursor(lA, cA)
  if A == open_delim
    exe 'norm! "_' .. repeat('X', len(open_delim))
    # exe $"norm! {len(open_delim)}X"
    if lA == lB
      offset -= len(open_delim)
    endif
  else
    exe $"norm! i{open_delim}"
    if lA == lB
      offset += len(open_delim)
    endif
  endif

  cursor(lB, cB + offset)
  if B == close_delim
    exe 'norm! l"_' .. repeat('x', len(close_delim))
    # exe $"norm! l{len(close_delim)}x"
  else
    exe $"norm! a{close_delim}"
  endif

  setpos('.', save_cursor)

enddef

def SetSurroundOpFunc(open_delim: string, close_delim: string)
  &opfunc = function(Surround, [open_delim, close_delim])
enddef

if exists('g:op_surround_maps')
  for item in g:op_surround_maps
    if empty(maparg(item.map, 'n'))
      exe $"nnoremap {item.map} <ScriptCmd>SetSurroundOpFunc("
           .. $" '{item.open_delim}', '{item.close_delim}')<cr>g@"
    endif
    if empty(maparg(item.map, 'x'))
      exe $"xnoremap {item.map} <ScriptCmd>SetSurroundOpFunc("
           .. $" '{item.open_delim}', '{item.close_delim}')<cr>g@"
    endif
  endfor
endif

def OpSurroundMakeMappings()
  if exists('g:op_surround_maps')
    for item in g:op_surround_maps
      if empty(maparg(item.map, 'n'))
        exe $"nnoremap {item.map} <ScriptCmd>SetSurroundOpFunc("
             .. $" '{item.open_delim}', '{item.close_delim}')<cr>g@"
      endif
      if empty(maparg(item.map, 'x'))
        exe $"xnoremap {item.map} <ScriptCmd>SetSurroundOpFunc("
             .. $" '{item.open_delim}', '{item.close_delim}')<cr>g@"
      endif
    endfor
  endif

  if exists('b:op_surround_maps')
    for item in b:op_surround_maps
      exe $"nnoremap <buffer> {item.map} <ScriptCmd>SetSurroundOpFunc("
           .. $" '{item.open_delim}', '{item.close_delim}')<cr>g@"
      exe $"xnoremap <buffer> {item.map} <ScriptCmd>SetSurroundOpFunc("
           .. $" '{item.open_delim}', '{item.close_delim}')<cr>g@"
    endfor
  endif
enddef

command! -nargs=0 OpSurroundMakeMappings OpSurroundMakeMappings()
