http = require 'http'
derby = require 'derby'
async = require 'async'
functions = require './functions'
{ onServer, removeDuplicates } = require '../lib/utils'

# This code is so unclear that it's pathetic
# TODO: Make it more obvious as to what it accomplishes
generateFn = (item, arr, page, model, params) ->
  if !model.get('_isFront')
    createFn = (item, callback) ->
      callback null, (callback) -> functions[item] {}, model, params, callback
    # Convert array of function names to array of async parallel functions
    async.map arr, createFn, (err, results) ->
      async.parallel results, ->
        functions[item] page, model, params
  else
    functions[item] page, model, params

controller =
  index: (page, model) -> functions.index page, model
  tiph: (page, model) -> functions.tiph page, model
  about: (page, model) -> functions.about page, model
  year: (page, model, params) -> generateFn 'year', ['index'], page, model, params
  show: (page, model, params) -> generateFn 'show', ['index','year'], page, model, params
  song: (page, model, params) -> generateFn 'song', ['index','year','show'], page, model, params

module.exports = controller

# import ready callback
require './ready'

# import view functions
require './viewFunctions'
