exports['test'] =
  setUp: (done) -> done()
  'basic test equals': (test) ->
    test.expect(1)
    test.equal(3,1+2)
    test.done()
  'basic no error': (test) ->
    test.ok(300 / 0)
    test.equal(Infinity, 300 / 0)
    test.done()
