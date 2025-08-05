vim9script

var save_surround_view = {}

def Surround(open_delim: string, close_delim: string, type: string = '')

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
  # var B = strgetchar(getline(lB), cB + strchars(close_delim) - 1)->nr2char()
  var B = strcharpart(getline(lB), cB, strchars(close_delim))

  setcursorcharpos(lA, cA)
  var offset = 0
  if A == open_delim
    exe 'norm! "_' .. repeat('X', strchars(open_delim))
    if lA == lB
      offset -= strchars(open_delim)
    endif
  else
    exe $"norm! i{open_delim}"
    if lA == lB
      offset += strchars(open_delim)
    endif
  endif

  setcursorcharpos(lB, cB + offset)
  if B == close_delim
    exe 'norm! l"_' .. repeat('x', strchars(close_delim))
  else
    exe $"norm! a{close_delim}"
  endif

  if !empty('save_surround_view')
    winrestview(save_surround_view)
    save_surround_view = {}
  endif
enddef

export def SetSurroundOpFunc(open_delim: string, close_delim: string)
  save_surround_view = winsaveview()
  &opfunc = function(Surround, [open_delim, close_delim])
enddef

# carry over (and modified) from vim-markdown-extras
def IsInRange(): dict<list<list<number>>>
  # Return a dict like {'synID': [[21, 19], [22, 21]]}.
  # The returned intervals are open.

  def SearchPosChar(pattern: string, options: string): list<number>
    # Like 'searchpos()' but the column is converted in char index
    var [l, c] = searchpos(pattern, options)
    var c_char = charidx(getline(l), c - 1) + 1
    return [l, c_char]
  enddef

  # ================================
  # Main function start here
  # ================================
  # TODO: text_style comes from vim-markdown. If vim-markdown changes, this will.
  # It is not enough to find separators, but such separators must be
  # named '*Delimiter' according to synIDAttr()
  const text_style = synIDattr(synID(line("."), col("."), 1), "name")
  var return_val = {}

  if !empty(text_style_adjusted)
      && index(keys(constants.TEXT_STYLES_DICT), text_style_adjusted) != -1

    const saved_curpos = getcursorcharpos()

    # Search start delimiter
    const open_delim =
      eval($'constants.TEXT_STYLES_DICT.{text_style_adjusted}.open_delim')

    var open_delim_pos = SearchPosChar($'\V{open_delim}', 'bW')

    var current_style = synIDattr(synID(line("."), col("."), 1), "name")

    # To avoid infinite loops if some weird delimited text is highlighted
    if open_delim_pos == [0, 0]
      return {}
    endif
    open_delim_pos[1] += strchars(open_delim)

    # ----- Search end delimiter. -------
    # The end delimiter may be a blank line, hence
    # things become a bit cumbersome.
    setcursorcharpos(saved_curpos[1 : 2])
    const close_delim =
     eval($'constants.TEXT_STYLES_DICT.{text_style_adjusted}.close_delim')
    var close_delim_pos = SearchPosChar($'\V{close_delim}', 'nW')
    var blank_line_pos = SearchPosChar('^$', 'nW')
    var first_met = [0, 0]
    current_style = synIDattr(synID(line("."), col("."), 1), "name")

    if close_delim_pos == [0, 0]
      first_met = blank_line_pos
    elseif blank_line_pos == [0, 0]
      first_met = close_delim_pos
    else
      first_met = IsLess(close_delim_pos, blank_line_pos)
        ? close_delim_pos
        : blank_line_pos
    endif
    setcursorcharpos(first_met)
    current_style = synIDattr(synID(line("."), col("."), 1), "name")
    # If we hit a blank line, then we take the previous line and last column,
    # to keep consistency in returning open-intervals
    if getline(line('.')) =~ '^$'
      first_met[0] = first_met[0] - 1
      first_met[1] = strchars(getline(first_met[0]))
    else
      first_met[1] -= 1
    endif

    setcursorcharpos(saved_curpos[1 : 2])
    return_val =  {[text_style_adjusted]: [open_delim_pos, first_met]}
  endif

  return return_val
enddef

# carry over from vim-markdown-extras
export def RemoveSurrounding(range_info: dict<list<list<number>>> = {})
    const style_interval = empty(range_info) ? IsInRange() : range_info

    const user_maps = exists('b:op_surround_maps') != -1
    ? b:op_surround_maps
    : g:op_surround_maps

    if !empty(style_interval)
      const style = keys(style_interval)[0]
      const interval = values(style_interval)[0]

      # Remove left delimiter
      const lA = interval[0][0]
      const cA = interval[0][1]
      const lineA = getline(lA)
      var newline = strcharpart(lineA, 0,
              \ cA - 1 - strchars(constants.TEXT_STYLES_DICT[style].open_delim))
              \ .. strcharpart(lineA, cA - 1)
      setline(lA, newline)

      # Remove right delimiter
      const lB = interval[1][0]
      var cB = interval[1][1]

      # Update cB.
      # If lA == lB, then The value of cB may no longer be valid since
      # we shortened the line
      if lA == lB
        cB = cB - strchars(constants.TEXT_STYLES_DICT[style].open_delim)
      endif

      # Check if you hit a delimiter or a blank line OR if you hit a delimiter
      # but you also have a blank like
      # If you have open intervals (as we do), then cB < lenght_of_line, If
      # not, then don't do anything. This behavior is compliant with
      # vim-surround
      const lineB = getline(lB)
      if  cB < strchars(lineB)
        # You have delimters
        newline = strcharpart(lineB, 0, cB)
              \ .. strcharpart(lineB,
                \ cB + strchars(constants.TEXT_STYLES_DICT[style].close_delim))
      else
        # You hit the end of paragraph
        newline = lineB
      endif
      setline(lB, newline)
    endif
enddef
