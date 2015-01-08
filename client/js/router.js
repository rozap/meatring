var _ = require('underscore');
var Backbone = require('backbone');

var Roots = require('./views/roots');
var Post = require('./views/post');
var Dispatcher = require('./dispatcher');

module.exports = Backbone.Router.extend({

	routes: {
		'post/:key': "post",
		'': "index"
	},

	initialize: function(opts) {
		var dispatcher = new Dispatcher(function(err) {
			if(err) console.warn("Error setting up socket, proceed in boring mode")
			Backbone.history.start();
		});
		this.app = {
			dispatcher: dispatcher.emitter(),
			router: this
		};

	},

	_create: function(View, opts) {
		if (this._view) this._view.end();
		this._view = new View(_.extend({
			app: this.app
		}, opts));
		this._view.onStart();
	},

	index: function() {
		console.log("index")
		this._create(Roots);
	},

	post: function(parentPost) {
		console.log("post");
		this._create(Post, {
			parentPost : parentPost
		})
	}

});