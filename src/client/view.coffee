# Client Views
# ------------
# Generates HTML output for each single-page view 

pathlib = require('path')
magicPath = require('./magic_path')
asset = require('./asset')
engine = require('./template_engine')


module.exports = (root, client, cb) ->

  # Add links to CSS and JS files
  includes = headers(root, client)

  # Add any Client-side Templates
  includes = includes.concat( templates(root, client) )

  # Output HTML
  options = {headers: includes.join(''), compress: client.pack, filename: client.paths.view}
  asset.html(root, client.paths.view, options, cb)


# Private

templates = (root, client) ->

  dir = pathlib.join(root, 'client/templates')
  
  output = []

  if client.paths.tmpl
    files = []
    client.paths.tmpl.forEach (tmpl) ->
      files = files.concat(magicPath.files(dir, tmpl))
    
    engine.generate dir, files, (templateHTML) ->
      output.push(templateHTML)

  output


headers = (root, client) ->

  # Return an array of headers. Order is important!
  output = []

  # If assets are packed, we only need one CSS and one JS file
  if client.pack
    
    output.push tag.css("/assets/#{client.name}/#{client.id}.css")
    output.push tag.js("/assets/#{client.name}/#{client.id}.js")

  # Otherwise, in development, list all files individually so debugging is easier
  else

    # SocketStream sytstem libs and modules
    output.push tag.js("/_serveDev/system?ts=#{client.id}")

    # Send all CSS
    client.paths.css.forEach (path) ->
      magicPath.files(root + '/client/css', path).forEach (file) ->
        output.push tag.css("/_serveDev/css/#{file}?ts=#{client.id}")

    # Send Application Code
    client.paths.code.forEach (path) ->
      magicPath.files(root + '/client/code', path).forEach (file) ->
        output.push tag.js("/_serveDev/code/#{file}?ts=#{client.id}&pathPrefix=#{path}")

    # Start your app and connect to SocketStream
    output.push tag.js("/_serveDev/start?ts=#{client.id}")

  output


# Helpers to generate HTML tags
tag =

  css: (path) ->
    '<link href="' + path + '" media="screen" rel="stylesheet" type="text/css">'

  js: (path) ->
    '<script src="' + path + '" type="text/javascript"></script>'
