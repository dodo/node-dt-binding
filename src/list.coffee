adiff = require 'adiff'
{ List } = require 'dt-list'
{ slice } = Array.prototype
{ isArray } = Array
{ Binding, multiplex } = require './binding'

# use an even simpler equals comparator for adiff
adiff = adiff({
    equal: (a, b) ->
        return no if a and not b
        return no if isArray(a) and a.length isnt b.length
        return a is b
}, adiff)

createBinding = (value) ->
    return value unless value and typeof value is 'object'
    return new ListBinding value

boundpartial = (create, value, args...) ->
    binding = createBinding value
    partial = create(binding, args...)
    partial._bind = binding if typeof binding is 'object'
    return partial

listadd = (items, create, old, value) ->
    added = []
    for val, i in value
        partial = boundpartial create, val, i
        added.push partial
        # apply patch!
        items.push partial
    # cache old value to diff it later against new value
    old.value = slice.call(value)
    return [added, [], []]

listrm = (items, old) ->
    removed = []
    while items.length
        # apply patch! … and remove all dead hard
        item = items.pop()?.remove(soft:no)
        removed.push item if item?
    # cache old value to diff it later against new value
    old.value = []
    return [[], [], removed]

listsync = (items, create, old, value) ->
    [added, changed, removed] = [[], [], []]
    # apply diff patches on items list
    old_items = slice.call(items)
    for patch in adiff.diff(old.value, value)
        # remove all items from dom before splicing them in
        for i in [(patch[0]) ... (patch[0]+patch[1])] when changed.indexOf(items[i]) is -1
            removed.push items[i]
        # replace values with items
        for n in [2 ... patch.length]
            i = old.value.indexOf(patch[n])
            if i is -1
                # create new value
                patch[n] = boundpartial create, patch[n], patch[0] + n - 2
                added.push patch[n]
            else
                # restore existing item to be spliced back into items
                patch[n] = old_items[i]
                changed.push old_items[i]
                old_items[i].remove(soft:yes)
                r = removed.indexOf(old_items[i])
                removed.splice(r, 1) unless r is -1
        # apply patch!
        items.splice.apply(items, patch)
    # remove all dead hard
    for item in removed
        item.remove(soft:no)
    # cache old value to diff it later against new value
    old.value = slice.call(value)
    return [added, changed, removed]

listswitch = (items, create, old, value) ->
    [old_len, len] = [old.value.length, value.length]
    # fasten some cases
    if not old_len and not len
        [[], [], []]
    else if old_len and not len
        listrm(items, old)
    else if not old_len and len
        listadd(items, create, old, value)
    else # we dont know better
        listsync(items, create, old, value)

listpartialize = (items, create, old, value = []) ->
    [added, changed, removed] = listswitch(items, create, old, value)
    # readd changed items and sliced back in items
    for item in changed
        @add(item)
    # add newly created items
    for itempartial in added
        @partial(itempartial)
    return this

listpartial = (items, create, old, value) ->
    partial = boundpartial create, value
    items.push(partial)
    @partial(partial)
    old.value.push(value)
    return partial


class ListBinding extends Binding

    constructor: ->
        @items = {}
        @values = {}
        @partials = {}
        super

    repeat: (key, callback = 'text', args...) ->
        that = this
        old = {value:[]}
        items = new List
        multiplex key, callback, args, (key, callback) ->
            that.items[key] = items
            that.values[key] = old
            that.partials[key] = listpartial.bind this, items, callback, old
            (that._binds[key] ?= []).push(listpartialize.bind this, items, callback, old)
            listpartialize.call this, items, callback, old, that.get(key)

    unbind: (key) ->
        delete @items[key] if @items[key]?
        delete @values[key] if @values[key]?
        delete @partials[key] if @partials[key]?
        super

    set: (key, value) ->
        data = @data
        keys = key.split('.')
        last_key = keys.pop()

        curkey = ''
        for k, i in keys
            curkey += (curkey and '.' or '') + k
            next = data[k]
            next = next.call(data) if typeof next is 'function'
            data = next
            if isArray(data)
                k = keys.pop() # index
                restkeys = keys.slice(i + 1)
                restkeys.push(last_key)
                result = @items[curkey][k]?._bind?.set(restkeys.join('.'), value)
                @trigger key, result if @items[curkey][k]?._bind?
                return result
            break unless data?

        data?[last_key] = value
        @trigger key, value if data?
        return value

    addTo: (key, value) ->
        return @partials[key]?(value)

    removeFrom: (key, i) ->
        return unless @values[key]?
        @values[key].value.splice(i, 1)
        delete @items[i]._bind
        return @items.remove(i)



module.exports = ListBinding
ListBinding.Binding = ListBinding
ListBinding.ListBinding = ListBinding
ListBinding.listpartial = listpartial
ListBinding.listsync = listsync
ListBinding.listadd = listadd
ListBinding.listrm = listrm
