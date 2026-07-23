vim9script

var save_surround_view = {}

export def Echoerr(msg: string)
  echohl ErrorMsg | echom $'[op-surround] {msg}' | echohl None
enddef

export def Echowarn(msg: string)
  echohl WarningMsg | echom $'[op-surround] {msg}' | echohl None
enddef

def Append(open_delim: string, close_delim: string, type: string = '')

  if getcharpos("'[") == getcharpos("']")
    return
  endif

  # line and column of point A
  var lA = line("'[")
  var cA = type == 'line' ? 1 : charcol("'[")
  # line and column of point B
  var lB = line("']")
  var cB = type == 'line' ? strchars(getline(lB)) : charcol("']")

  setcursorcharpos(lA, cA)
  exe $"norm! i{open_delim}"

  const offset = lA == lB ? strchars(open_delim) : 0
  setcursorcharpos(lB, cB + offset)
  exe $"norm! a{close_delim}"

  if !empty('save_surround_view')
    winrestview(save_surround_view)
    save_surround_view = {}
  endif
enddef


def Delete(open_delim: string, close_delim: string, type: string = '')

  if getcharpos("'[") == getcharpos("']")
    return
  endif

  # line and column of point A
  var lA = line("'[")
  var cA = type == 'line' ? 1 : charcol("'[")
  # line and column of point B
  var lB = line("']")
  var cB = type == 'line' ? strchars(getline(lB)) : charcol("']")

  # Pick chars just before cA (attempt to get an open_delim)
  var A = strcharpart(getline(lA), cA - strchars(open_delim) - 1, strchars(open_delim))
  # Pick chars just after cB (attempt to get a close_delim)
  var B = strcharpart(getline(lB), cB, strchars(close_delim))

  setcursorcharpos(lA, cA)
  var offset = 0
  if A == open_delim
    exe 'norm! "_' .. repeat('X', strchars(open_delim))
    if lA == lB
      offset -= strchars(open_delim)
    endif
  endif

  setcursorcharpos(lB, cB + offset)
  if B == close_delim
    exe 'norm! l"_' .. repeat('x', strchars(close_delim))
  endif

  if !empty('save_surround_view')
    winrestview(save_surround_view)
    save_surround_view = {}
  endif
enddef

export def SetSurroundOpFunc(open_delim: string, close_delim: string, action: string)
  save_surround_view = winsaveview()
  if action == 'append'
    &opfunc = function(Append, [open_delim, close_delim])
  elseif action == 'delete'
    &opfunc = function(Delete, [open_delim, close_delim])
  else
    Echoerr("'action' must be 'append' or 'delete'")
  endif
enddef
