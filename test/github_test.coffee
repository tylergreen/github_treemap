github = require '../lib/github'

exports['test'] =
  setUp: (done) ->
    @flat_test_tree = [ {file: 'a.txt'}, {file: 'b.txt'}, {file: 'c.txt'}]
    @test_tree = [ {file: '.gitignore'},
      {file: 'init.el'},
      {directory: 'lisp',
      contents: [ {file: 'borg.el'}, {file: 'my-ruby.el'}, {file: 'my-utils.el'}]}
      {directory: 'tests', contents: [ {file: 'utils_test.el'} ]}]
    done()
  'basic test equals': (test) ->
    test.expect(1)
    test.equal(3,1+2)
    test.done()

  'basic no error': (test) ->
    test.ok(300 / 0)
    test.equal(Infinity, 300 / 0)
    test.done()

  'module test': (test) ->
    test.expect(1)
    test.equal(3,github.x())
    test.done()

  'request test': (test) ->
    test.expect(1)
    path = '/repos/tylergreen/flat_test_repo/contents/'
    github.ls_files(path, (files) ->
      test.deepEqual([ 'a.txt', 'b.txt', 'c.txt'], files)
      test.done()
    )

  'get tree structure of a local dir': (test) ->
    test.expect(1)
    github.walk('test/nested_test_repo', (err, results) ->
      expected = [ 'test/nested_test_repo/a.txt',
       'test/nested_test_repo/c.txt',
       'test/nested_test_repo/b/b-a.txt' ]
      test.deepEqual(expected, results)
      test.done()
    )

  'get the recursive tree structure of a flat repository': (test) ->
    test.expect(1)
    path = '/repos/tylergreen/flat_test_repo/contents/'
    github.directory_tree(path, (tree) ->
      test.deepEqual(tree,@flat_test_tree)
      test.done()
    )
