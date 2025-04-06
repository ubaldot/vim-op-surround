vim9script

# Test for the vim-markdown plugin
# Copied and adjusted from Vim distribution

import "./common.vim"

# Test file 1
var file_name = 'testfile.txt'
var text =<< trim END
      Sed ut perspiciatis unde omnis iste natus error sit voluptatem
      accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae
      ab illo inventore veritatis et quasi architecto beatae vitae dicta
      sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit
      aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos
      qui ratione voluptatem sequi nesciunt.
END

def Generate_testfile(lines: list<string>, src_name: string)
   writefile(lines, src_name)
enddef

def Cleanup_testfile(src_name: string)
   delete(src_name)
enddef

# Tests start here
def g:Test_generic()
  Generate_testfile(text, file_name)
  vnew
  exe $"edit {file_name}"
  setlocal spell spelllang=la

  g:op_surround_maps = [
    {map: "((", open_delim: "(", close_delim: ")"},
    {map: "[[", open_delim: "[", close_delim: "]"},
  ]
  OpSurroundMakeMaps
  cursor(1, 12)
  exe "norm ((iw"
  var expected_value =
    "Sed ut (perspiciatis) unde omnis iste natus error sit voluptatem"
  assert_equal(expected_value, getline(1))

  cursor(1, 12)
  exe "norm ((iw"
  expected_value =
    "Sed ut perspiciatis unde omnis iste natus error sit voluptatem"
  assert_equal(expected_value, getline(1))

  cursor(1, 8)
  exe "norm [[tu"
  expected_value =
    "Sed ut [perspiciatis ]unde omnis iste natus error sit voluptatem"
  assert_equal(expected_value, getline(1))

  cursor(1, 12)
  exe "norm [[i["
  expected_value =
    "Sed ut perspiciatis unde omnis iste natus error sit voluptatem"
  assert_equal(expected_value, getline(1))

  cursor(1, 8)
  exe "norm vje[["
  const expected_value_1_2 = [
  'Sed ut [perspiciatis unde omnis iste natus error sit voluptatem',
  'accusantium] doloremque laudantium, totam rem aperiam, eaque ipsa quae'
  ]
  assert_equal(expected_value_1_2, getline(1, 2))
  # redraw!
  # sleep 3
  :%bw!
  Cleanup_testfile(file_name)
enddef
