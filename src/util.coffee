isArray = Array.isArray

deep_get = (data, keys) ->
    return unless data?
    return data unless keys.length
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

# callback can be either string or function or object of string or function values
functionify = (callback, args) ->
    if typeof callback is 'function'
        return (moargs...) ->
            callback.apply(this, args.concat moargs)
    if isArray(callback)
        methods = callback
        callback = (moargs...) ->
            for method in methods
                [method, args...] = if isArray(method) then method else [method]
                this[method]?.apply(this, args.concat moargs)
            return
        callback.method = methods
    else
        method = callback
        callback = (moargs...) ->
            this[method]?.apply(this, args.concat moargs)
        callback.method = method
    return callback

# key can be either string or object of callback values
multiplex = (key, callback, args, action) ->
    if typeof key is 'object'
        callbacks = key
        return () ->
            for key, callback of callbacks
                callback = functionify callback, args
                action.call this, key, callback.bind(this)
    else
        callback = functionify callback, args
        return () ->
            action.call this, key, callback.bind(this)

# exports

module.exports = {
    deep_get, deep_set,
    functionify,
    multiplex,
}