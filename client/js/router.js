var _ = require('underscore');
var Backbone = require('backbone');

var Roots = require('./views/roots');
var Post = require('./views/post');


module.exports = Backbone.Router.extend({

	routes: {
		'post/:key': "post",
		'': "index"
	},

	initialize: function(opts) {
		this.app = {
			dispatcher: _.clone(Backbone.Events)
		};
		Backbone.history.start();

	},

	_create: function(View) {
		if (this._view) this._view.end();
		this._view = new View({
			app: this.app
		});
		this._view.onStart();
	},

	index: function() {
		console.log("index")
		this._create(Roots);
	},

	post: function() {
		console.log("post");
		this._create(Post)
	}

});