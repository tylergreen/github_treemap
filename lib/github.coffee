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
    res.on('end', -> next(null, JSON.parse(response)))
  )
  req.end()
  req.on('error', (err) -> next(err))

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
              results.push({directory: file, contents: res})
              pending--
              done(null, results) if pending == 0
            )
          else
            results.push({file: file})
            pending--
            done(null, results) if pending == 0
          )
        )
      )

dir_size = (directory) ->
  directory.contents.reduce((acc, branch) ->
    if branch.file
      acc + branch.size
    else
      acc + dir_size(branch)
  , 0 )

# innefficient version -- walks tree twice
annotate_dirs = (tree) ->
  tree.map((branch) ->
    if branch.file
      branch
    else
      branch.size = dir_size(branch)
      branch.contents = annotate_dirs(branch.contents)
      branch
  )

ls_files = (path, next) ->
  get_options['path'] = path
  github_request(get_options, (err, data) ->
    if err then next(err) else next(null, data))

directory_tree = (dir, done) ->
  directory_tree_aux(dir, (err, tree) ->
    if err then done(err) else done(null, annotate_dirs(tree)))

# would like to abstract the walking of the tree from the operations on the nodes
directory_tree_aux = (dir, done) ->
    results = []
    ls_files(dir, (err, list) ->
      if err
        done(err)
      else
        pending = list.length
        done(null, results) if (pending == 0)
        list.forEach((file) ->
          path = "#{dir}/#{file.name}"
          if file.type == 'dir'
            directory_tree_aux(path, (err,res) ->
              if err
                done(err)
              else
                results.push({directory: path, contents: res})
                pending--
                done(null, results) if pending == 0)
          else
            results.push({file: path, size: file.size})
            pending--
            done(null, results) if pending == 0
        )
      )


module.exports =
 x : () -> 3
 ls_files: ls_files
 directory_tree: directory_tree

module.exports['walk'] = walk
module.exports['dir_size'] = dir_size
module.exports['annotate_dirs'] = annotate_dirs