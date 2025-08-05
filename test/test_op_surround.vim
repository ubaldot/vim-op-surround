vim9script

import "./common.vim"

def Generate_testfile(lines: list<string>, src_name: string)
   writefile(lines, src_name)
enddef

def Cleanup_testfile(src_name: string)
   delete(src_name)
enddef

# Tests start here
def g:Test_generic()
  # Test file
  const file_name = 'testfile.txt'
  const text =<< trim END
        Sed ut perspiciatis unde omnis iste natus error sit voluptatem
        accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae
        ab illo inventore veritatis et quasi architecto beatae vitae dicta
        sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit
        aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos
        qui ratione voluptatem sequi nesciunt.
  END

  Generate_testfile(text, file_name)
  vnew
  exe $"edit {file_name}"
  setlocal spell spelllang=la

  g:op_surround_maps = [
    {map: "sa(", open_delim: "(", close_delim: ")", action: 'append'},
    {map: "sd(", open_delim: "(", close_delim: ")", action: 'delete'},
    {map: "sa[", open_delim: "[", close_delim: "]", action: 'append'},
    {map: "sd[", open_delim: "[", close_delim: "]", action: 'delete'},
  ]
  OpSurroundMakeMappings

  cursor(1, 12)
  exe "norm sa(iw"
  var expected_value =
    "Sed ut (perspiciatis) unde omnis iste natus error sit voluptatem"
  assert_equal(expected_value, getline(1))

  cursor(1, 12)
  exe "norm sd(iw"
  expected_value =
    "Sed ut perspiciatis unde omnis iste natus error sit voluptatem"
  assert_equal(expected_value, getline(1))

  cursor(1, 8)
  exe "norm sa[tu"
  expected_value =
    "Sed ut [perspiciatis ]unde omnis iste natus error sit voluptatem"
  assert_equal(expected_value, getline(1))

  cursor(1, 12)
  exe "norm sd[i["
  expected_value =
    "Sed ut perspiciatis unde omnis iste natus error sit voluptatem"
  assert_equal(expected_value, getline(1))

  cursor(1, 8)
  exe "norm vjesa["
  const expected_value_1_2 = [
  'Sed ut [perspiciatis unde omnis iste natus error sit voluptatem',
  'accusantium] doloremque laudantium, totam rem aperiam, eaque ipsa quae'
  ]
  assert_equal(expected_value_1_2, getline(1, 2))

  # # open_delim differs from close_delim and multi-chars
  b:op_surround_maps = [
    {map: "sa(", open_delim: "<div>", close_delim: "</div>", action: 'append'},
    {map: "sd(", open_delim: "<div>", close_delim: "</div>", action: 'delete'},
  ]
  OpSurroundMakeMappings

  cursor(6, 14)
  exe "norm sa(iw"
  var expected_value_6 = "qui ratione <div>voluptatem</div> sequi nesciunt."
  assert_equal(expected_value_6, getline(6))

  cursor(6, 23)
  exe "norm sd(iw"
  expected_value_6 = "qui ratione voluptatem sequi nesciunt."
  assert_equal(expected_value_6, getline(6))

  # # Remove maps
  for item in g:op_surround_maps
    exe $"unmap {item.map}"
  endfor

  :%bw!
  Cleanup_testfile(file_name)
enddef

def g:Test_multibyte()
  # Test file
  const file_name = 'testfile_chinese.txt'
  const text =<< trim END
  当然可以，以下是一段中文文本：

  在现代社会中，科技的迅速发展改变了人们的生活方式。从智能手机到人工智能，
  人们越来越依赖技术来完成日常任务。
  虽然科技带来了极大的便利，但也引发了一些新的问题，例如隐私泄露和信息过载。
  因此，我们在享受科技成果的同时，也需要保持理性思考，平衡科技与人文之间的关系。
  END

  Generate_testfile(text, file_name)
  vnew
  exe $"edit {file_name}"


  b:op_surround_maps = [
    {map: "sa(", open_delim: "(", close_delim: ")", action: 'append'},
    {map: "sd(", open_delim: "(", close_delim: ")", action: 'delete'},
    {map: "sa[", open_delim: "[", close_delim: "]", action: 'append'},
    {map: "sd[", open_delim: "[", close_delim: "]", action: 'delete'},
  ]
  OpSurroundMakeMappings

  messages clear
  setcursorcharpos(1, 8)
  exe "norm sa(iw"
  var expected_value = "当然可以，(以下是一段中文文本)："
  assert_equal(expected_value, getline(1))

  exe "norm sd(iw"
  expected_value = "当然可以，以下是一段中文文本："
  assert_equal(expected_value, getline(1))

  setcursorcharpos(3, 8)
  exe "norm vj[["
  var expected_value_multiline =<< trim END
    在现代社会中，\[科技的迅速发展改变了人们的生活方式。从智能手机到人工智能，
    人们越来越依赖技\]术来完成日常任务。
  END
  assert_equal(expected_value_multiline, getline(3, 4))

  # Multibyte delimiter
  # If we keep the current buffer mapping '((', then such a mapping will not
  # be overwritten if we try to remap '(('
  exe "unmap <buffer> sa("
  exe "unmap <buffer> sd("
  b:op_surround_maps = [
    {map: "sa(", open_delim: "〈", close_delim: "〉", action: 'append'},
    {map: "sd(", open_delim: "〈", close_delim: "〉", action: 'delete'},
  ]
  OpSurroundMakeMappings

  setcursorcharpos(6, 5)
  exe "norm sa(t，"
  expected_value = "因此，我〈们在享受科技成果的同时〉，"
     .. "也需要保持理性思考，平衡科技与人文之间的关系。"
  assert_equal(expected_value, getline(6))

  :%bw!
  Cleanup_testfile(file_name)
enddef
