https = require 'https'
_ = require 'underscore'
async = require 'async'
fs = require 'fs'

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

walk = (dir, done) ->
    results = []
    fs.readdir(dir, (err, list) ->
      done(err) if err
      pending = list.length
      done(null, results) if (pending == 0)
      list.forEach((file) ->
        file = "#{dir}/#{file}"
        fs.stat(file, (err,stat) ->
          if stat and stat.isDirectory()
            walk(file, (err,res) ->
              results = results.concat(res)
              pending--
              done(null, results) if pending == 0
            )
          else
            results.push(file)
            pending--
            done(null, results) if pending == 0
          )
        )
      )


module.exports =
 x : () -> 3

 ls_files : (path, next) ->
  get_options['path'] = path
  github_request(get_options, (data) ->
    files = data.map((x) -> x.name)
    next(files))

 directory_tree: (path,next) ->
  get_options['path'] = path
  github_request(get_options, (err, data) ->
    if err
      #console.log("error: #{err}") if err
      next(err)
    else
      # need to define the map and reduce step, otherwise infinite regression.
      files = data.filter((x) -> x.type == 'file')
      file_names = files.map((f) -> {file: f.name})
      dirs = data.filter((x) -> x.type == 'dir')
      async.map(dirs, (dir) ->
        directory_tree(path + dir, (contents) ->
          files = data.map((x) -> x.name)
          next(contents)
        )
      )
    )

module.exports['walk'] = walk