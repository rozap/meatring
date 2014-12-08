var Router = require('./router');
var Backbone = require('backbone');
var $ = require('jquery');
Backbone.$ = $;

$(document).ready(function( ){
	new Router();
})
