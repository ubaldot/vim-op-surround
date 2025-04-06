# Tests

Setup is copied and adapted from yegappan/lsp.

Tests are executed on the same Vim instance. Variables will not be cleaned!
To run the tests in different Vim instances, then you have to include a for
loop in the .cmd or .sh script with the tests that you want to run with fresh
vim --clean instances.

Use sleep to see what happens on screen, if needed, and echom assert_* to see
the results.

Each test function name shall start with g:Test_*. and shall finish with

  :%bw!
  Cleanup_markdown_testfile()

This secure that the text object is always reloaded clean and that at after
the last test is removed.
