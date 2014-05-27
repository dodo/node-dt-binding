{ slice } = Array.prototype
isArray = Array.isArray

deep_get = (data, keys) ->
    return unless data?
    for key in keys.split('.')
        next = data[key]
        next = next.call(data) if typeof next is 'function'
        data = next
        break unless data?
    return data

deep_set = (data, keys, value) ->
    return unless data?
    keys = keys.split('.')
    key = keys.pop()
    data = deep_get data, keys.join('.')
    return data?[key] = value

functionify = (callback, args) ->
    unless typeof callback is 'function'
        if isArray(callback)
            methods = callback
            callback = (value) ->
                for method in methods
                    [method, args...] = if isArray(method) then method else [method]
                    this[method]?.apply(this, args.concat [value])
                return
            callback.method = methods
        else
            method = callback
            callback = (value) ->
                this[method]?.apply(this, args.concat [value])
            callback.method = method
    else
        return (value) ->
            callback.apply(this, args.concat [value])
    return callback

multiplex = (key, callback, args, action) ->
    if typeof key is 'object'
        callbacks = key
        return () ->
            for key, callback of callbacks
                callback = functionify callback, args
                action.call this, key, callback
    else
        callback = functionify callback, args
        return () ->
            action.call this, key, callback


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
        return this

    set: (key, value) ->
        deep_set @data, key, value
        @trigger key, value
        return value

    get: (key) ->
        return deep_get @data, key

    change: (data = {}) ->
        for key, value of data
            @set key, value
        return this

Binding.multiplex = multiplex
Binding.Binding = Binding
module.exports = Binding
