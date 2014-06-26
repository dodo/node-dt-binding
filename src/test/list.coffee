{ EventEmitter } = require 'events'
jQuery = require 'jQuery'
{ Template } = require 'dynamictemplate'
{ Binding } = require '../list'

jqueryify = (opts, tpl) ->
    opts.use = require 'dt-list/adapter/jquery'
    require('dt-jquery')(opts, tpl)

HTML = ($,el) ->
    $div = $('<div>')
    $div.append(el.clone())
    $div.html() or "<empty/>" # m(

module.exports =

    setUp: (callback) ->
        @$ = jQuery.create()
        @html = (el) => HTML(@$,el)
        callback()

    binding:
        setUp: (callback) ->
            @api = new EventEmitter
            @results = "no results"
            setTimeout =>
                @æ.equal @html(@tpl.jquery), @results.join("")
                @æ.done()
            , 100
            callback()


        initial: (æ) ->
            @æ = æ ; { $, api } = this
            data = new Binding {
                title: "foobar"
                css:   "fun.css"
                content: [
                    {
                        type: 'header'
                        body: "foobar"
                    },
                    {
                        type: 'main'
                        body: "hello world"
                    },
                    {
                        type: 'footer'
                        body: "big foot"
                    },
                ]
            }
            tpl = @tpl = jqueryify {$}, new Template schema:5, ->
                @$html ->
                    @$head ->
                        @$title data.bind 'title'
                        @$link type:'text/css', data.bind 'css', 'attr', 'href'
                    @$body data.repeat 'content', (content) ->
                        this['$' + content.get 'type'](content.bind 'body')

            @results = [
                '<html>'
                "<head>"
                "<title>foobar</title>"
                '<link type="text/css" href="fun.css">'
                "</head>"
                "<body>"
                "<header>foobar</header>"
                "<main>hello world</main>"
                "<footer>big foot</footer>"
                "</body>"
                "</html>"
            ]


        change: (æ) ->
            @æ = æ ; { $, api } = this
            data = new Binding {
                title: "foobar"
                css:   "fun.css"
                content: [
                    {
                        type: 'header'
                        body: "foobar"
                    },
                    {
                        type: 'main'
                        body: "hello world"
                    },
                ]
            }
            tpl = @tpl = jqueryify {$}, new Template schema:5, ->
                @$html ->
                    @$head ->
                        @$title data.bind 'title'
                        @$link type:'text/css', data.bind 'css', 'attr', 'href'
                    @$body data.repeat 'content', (content) ->
                        attrs = content.get('attrs') ? {}
                        this['$' + content.get 'type'](attrs, content.bind 'body')

            setTimeout ->
                data.addTo 'content', {
                    type: 'footer'
                    body: "big foot"
                }
            , 16

            setTimeout ->
                data.set 'content.0.body', "honking"
            , 23
            setTimeout ->
                data.set 'content.2.body', "trololo"
            , 42
            setTimeout ->
                data.set 'css', "pink.css"
            , 64

            @results = [
                '<html>'
                "<head>"
                "<title>foobar</title>"
                '<link type="text/css" href="pink.css">'
                "</head>"
                "<body>"
                "<header>honking</header>"
                "<main>hello world</main>"
                "<footer>trololo</footer>"
                "</body>"
                "</html>"
            ]

