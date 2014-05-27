{ Template } = require 'dynamictemplate'
render = require 'dynamictemplate/render'
{ ListBinding } = require './list'



template = (data) ->
    new Template schema:5, pretty:on, ->
        @$html ->
            @$head ->
                @$title "test"
            @$body -> @$main ->
                @$div class:'foo', ->
                    @$span 'foobar'
                @$ul class:'users', data.repeat 'users', (user) ->
                    @$li class:'user', ->
                        user.bind('title', 'attr', 'title').call(this)
                        @$div class:'name', user.bind {
                            'name':  'text',
                            'age':  ['attr', 'data-age'],
                            'repo': ['attr', 'data-repo'],
                        }
                        @$div class:'repo', user.bind 'repo'
                        @$div class:'age',  user.bind 'age'
                        @$div class:'box',  user.bind 'box.color', 'attr', 'data-color'
                @$h3 "next lotto numbers are …"
                @$ul class:'numbers', data.repeat 'lotto', '$li'



numbers = for i in [1 .. 10]
    Math.round(Math.random() * 100)


data = new ListBinding({
    lotto: numbers,
    users:[
        {
            name:"foobar",
            age:  3,
            repo: "git",
            title: "red box",
            box: {
                color: "red",
            }
        },
        {
            name:"trololo",
            age:  6,
            repo: "hg",
            title: "pink box",
            box: {
                color: "pink",
            }
        },
    ],
})

tpl = template(data)

tpl.ready ->
    setTimeout ->
        data.set 'users.0.name', "trololo"
    , 500
    setTimeout ->
        data.set 'users.0.age', 6
    , 1500
    setTimeout ->
        data.set 'users.1.title', "green box"
        data.set 'users.1.box.color', "green"
    , 1500

render(tpl).pipe(process.stdout)
