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
    path = '/repos/tylergreen/flat_test_repo/contents/'
    github.ls_files(path, (err,files) ->
      test.deepEqual([ 'a.txt', 'b.txt', 'c.txt'], files.map((f) -> f.name))
      test.done()
    )

  'get tree structure of a local dir': (test) ->
    test.expect(1)
    github.walk('test/nested_test_repo', (err, results) ->
      expected = [ {file: 'test/nested_test_repo/a.txt'},
            {file: 'test/nested_test_repo/c.txt'},
            {directory: 'test/nested_test_repo/b', contents: [ {file: 'test/nested_test_repo/b/b-a.txt'}, {file: 'test/nested_test_repo/b/d.txt'}, {directory: 'test/nested_test_repo/b/c', contents: [] }   ] }
          ]
      test.deepEqual(results, expected)
      test.done()
    )

  'get the recursive tree structure of a flat repository': (test) ->
    test.expect(2)
    path = '/repos/tylergreen/flat_test_repo/contents'
    github.directory_tree(path, (err, tree) ->
      test.ifError(err)
      test_tree = [{"file":"/repos/tylergreen/flat_test_repo/contents/a.txt"},
          {"file":"/repos/tylergreen/flat_test_repo/contents/b.txt"},
          {"file":"/repos/tylergreen/flat_test_repo/contents/c.txt"}]
      test.deepEqual(tree,test_tree)
      test.done()
    )

  'get the recursive tree structure of a nested repository': (test) ->
    test.expect(2)
    path = '/repos/tylergreen/nested_test_repo/contents'
    github.directory_tree(path, (err, tree) ->
      test.ifError(err)
      test_tree =  [ { file: '/repos/tylergreen/nested_test_repo/contents/a.txt' },
          { file: '/repos/tylergreen/nested_test_repo/contents/c.txt' },
          { directory: '/repos/tylergreen/nested_test_repo/contents/b', contents: [ { file: '/repos/tylergreen/nested_test_repo/contents/b/b.txt' },
          { file: '/repos/tylergreen/nested_test_repo/contents/b/d.txt' } ] } ]
      test.deepEqual(tree,test_tree)
      test.done()
    )
