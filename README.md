# [Δt Data Bindings](https://github.com/dodo/node-dt-binding/)

This is data bindings for [Δt](http://dodo.github.com/node-dynamictemplate/).


## Installation

```bash
$ npm install dt-binding
```


## Usage

```javascript
var Template = require('dynamictemplate').Template;
var streamify = require('dt-stream');
var Binding = require('dt-binding');

var data = new Binding({
    title: "foobar",
    body: "hello world",
    css: "funny.css",
});
var template = streamify(new Template({schema:5, pretty:true}, function () {
    this.$html(function () {
        this.$head(function () {
            this.$title(data.bind('title'));
            this.$link({type:'text/css'}, data.bind('css', 'attr', 'href'));
        });
        this.$body(data.bind('body', 'text'));
    });
}));

template.stream.pipe(process.stdout);

/* → stdout:
<html>
   <head>
     <title>
       foobar
     </title>
     <link type="text/css" href="funny.css" />
   </head>
  <body>
    hello world
  </body>
</html>
*/
```

## api

TODO
