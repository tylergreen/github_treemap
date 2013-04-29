https = require 'https'
_ = require 'underscore'

get_options =
  host: 'api.github.com'
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

 ls_files : (path, next) ->
  get_options['path'] = path
  github_request(get_options, (data) ->
    files = data.map((x) -> x.name)
    next(files))

 directory_tree: (path,next) ->
  get_options['path'] = path
  github_request(get_options, (data) ->
    files = data.filter((x) -> x.type == 'file')
    files.map((f) -> {file: f.name})
    dirs = data.filter((x) -> x.type == 'dir')
    next([])
    #dirs # here is where we will need some async control flow
  )
