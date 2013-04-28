github = require '../lib/github'

exports['test'] =
  setUp: (done) ->
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
    github.repo_files((files) ->
      test.deepEqual([ '.gitignore', 'init.el', 'lisp', 'tests'], files)
      test.done()
    )

  'get the recursive tree structure': (test) ->
    test.expect(1)
    github.directory_tree((tree) ->
      test.deepEqual(tree,@test_tree)
      test.done()
    )
