var _ = require('underscore');
var View = require('./view');
var IndexTemplate = require('../../templates/roots.html');
var Posts = require('../collections/posts');
var Post = require('../models/post');
var MakePost = require('./make-post');

module.exports = View.extend({

    template: _.template(IndexTemplate),
    el: '#main',

    include: ['posts'],



    parentPost: 'root',

    MakePost: MakePost,


    onStart: function() {
        this.posts = new Posts([], {
            parentPost: this.parentPost
        });
        this.render();
        this.delegateMakePostEvents();
        this.listenTo(this.posts, 'sync', this.onFetched);
        this.posts.fetch();

        this.app.dispatcher.trigger('dht', 'watch:' + this.parentPost);
    },

    add: function(key) {
        var post = new Post({
            key: key
        });
        this.posts.add(post);
        post.fetch();

    },


    delegateMakePostEvents: function() {
        var events = {};
        var ev = 'click #make-' + this.parentPost + '-post-button';
        events[ev] = 'makePost';
        this.delegateEvents(events);
    },

    onFetched: function() {
        this.render();
    },


    makePost: function() {
        console.log("make post")
        this.spawn(new this.MakePost({
            app: this.app,
            el: '#make-' + this.parentPost + '-post',
            parentPost: this.parentPost
        }));
    }



});