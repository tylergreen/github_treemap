https = require 'https'
_ = require 'underscore'

options =
  host: 'api.github.com'
  path: '/repos/tylergreen/new-emacs/contents/'
  method: 'GET'
  headers:
    'User-Agent': 'Nodejs/1 Emacs/3'

github_request = (options, next) ->
  req = https.request(options, (res) ->
    response = ''
    res.on('data', (d) ->  response += d)
    res.on('end', -> next(JSON.parse(response)))
  )
  req.end()
  req.on('error', (e) -> console.error("error #{e}"))

module.exports =
 x : () -> 3
 repo_files : (next) ->
  github_request(options, (data) ->
    files = data.map((x) -> x.name)
    next(files))
 directory_tree: (next) ->
  next([])
