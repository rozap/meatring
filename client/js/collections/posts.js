var Backbone = require('backbone');

module.exports = Backbone.Collection.extend({

	initialize: function(models, opts) {
		this._parent = opts.parentPost;
		if (!this._parent) throw new Error("Specify a parent for the collection");
	},


	url: function() {
		return '/api/search/' + this._parent;
	}
});