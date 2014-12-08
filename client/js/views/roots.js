var _ = require('underscore');
var View = require('./view');
var IndexTemplate = require('../../templates/roots.html');
var Posts = require('../collections/posts');
var MakePost = require('./make-post');

module.exports = View.extend({

	template: _.template(IndexTemplate),
	el: '#main',

	include: ['posts'],

	events: {
		'click .make-post-button': 'makePost'
	},



	onStart: function() {

		this.posts = new Posts([], {
			parent: 'root'
		});
		this.render();

		this.listenTo(this.posts, 'sync', this.renderIt);
		this.posts.fetch();
	},


	makePost: function() {
		this.spawn('makePost', new MakePost({
			app: this.app,
			el: '#make-root-post',
			parentPost: 'root'
		}));
		this.render();
	}



});