{deep_get, deep_set, multiplex} = require './util'

class Binding
    constructor: (@data = {}) ->
        @_binds = {}

    bind: (key, callback = 'text', args...) ->
        that = this
        multiplex key, callback, args, (key, callback) ->
            (that._binds[key] ?= []).push(callback.bind this)
            callback.call this, that.get(key)

    unbind: (key, callback) ->
        if callback?
            callbacks = @_binds[key] ? []
            for fun, i in callbacks when callback is fun or fun.method is callback
                callbacks.splice(i, 1)
        else
            delete @_binds[key]
        return this

    trigger: (key, value) ->
        for callback in @_binds[key] ? []
            callback(value)
        if value and typeof value is 'object'
            for subkey, subval of value
                @trigger "#{key}.#{subkey}", subval
        return this

    set: (key, value) ->
        data = deep_set @data, key, value
        @trigger key, value if data?
        return value

    get: (key) ->
        return deep_get @data, key

    change: (data = {}) ->
        for key, value of data
            @set key, value
        return this

# exports

Binding.Binding = Binding
module.exports = Binding
