var _ = require('underscore');
var View = require('./view');
var IndexTemplate = require('../../templates/roots.html');
var Posts = require('../collections/posts');
var MakePost = require('./make-post');

module.exports = View.extend({

    template: _.template(IndexTemplate),
    el: '#main',

    include: ['posts'],



    parentPost: 'root',


    onStart: function() {
        this.delegateMakePostEvents();
        this.posts = new Posts([], {
            parentPost: this.parentPost
        });
        this.render();
        this.listenTo(this.posts, 'sync', this.onFetched);
        this.posts.fetch();
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
        this.spawn('makePost', new MakePost({
            app: this.app,
            el: '#make-' + this.parentPost + '-post',
            parentPost: this.parentPost
        }));
    }



});