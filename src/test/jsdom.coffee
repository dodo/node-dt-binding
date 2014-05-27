{ EventEmitter } = require 'events'
jQuery = require 'jQuery'
jqueryify = require 'dt-jquery'
{ Template } = require 'dynamictemplate'
{ Binding } = require '../binding'

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
                body:  "hello world"
                css:   "fun.css"
            }
            tpl = @tpl = jqueryify {$}, new Template schema:5, ->
                @$html ->
                    @$head ->
                        @$title data.bind 'title'
                        @$link type:'text/css', data.bind 'css', 'attr', 'href'
                    @$body data.bind 'body'

            @results = [
                '<html>'
                "<head>"
                "<title>foobar</title>"
                '<link type="text/css" href="fun.css">'
                "</head>"
                "<body>hello world</body>"
                "</html>"
            ]


        change: (æ) ->
            @æ = æ ; { $, api } = this
            data = new Binding {
                title: "foobar"
                body:  "hello world"
                css:   "fun.css"
            }
            tpl = @tpl = jqueryify {$}, new Template schema:5, ->
                @$html ->
                    @$head ->
                        @$title data.bind 'title'
                        @$link type:'text/css', data.bind 'css', 'attr', 'href'
                    @$body data.bind 'body'

            setTimeout ->
                data.set 'title', "honking"
            , 23
            setTimeout ->
                data.set 'body', "trololo"
            , 42
            setTimeout ->
                data.set 'css', "pink.css"
            , 64

            @results = [
                '<html>'
                "<head>"
                "<title>honking</title>"
                '<link type="text/css" href="pink.css">'
                "</head>"
                "<body>trololo</body>"
                "</html>"
            ]
