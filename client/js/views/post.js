var _ = require('underscore');
var View = require('./view');
var Roots = require('./roots');
var Post = require('../models/post');
var PostTemplate = require('../../templates/post.html');
var MakeSubPost = require('./make-sub-post');



var SubPostView = Roots.extend({
    include: ['parent', 'posts', 'parentPost'],
    template: _.template(PostTemplate),
    MakePost : MakeSubPost,

    onFetched: function() {
        this.render();
        this.posts.each(function(post) {
            this.spawn(new SubPostView({
                app: this.app,
                parentPost: post.get('key'),
                parent: post,
                el: '#sub-' + post.get('key') + '-posts'
            }), 'subPost' + post.get('key'));
        }.bind(this));
    }

});


var ParentPostView = SubPostView.extend({



    onStart: function() {
        this.delegateMakePostEvents();
        this.parent = new Post({
            key: this.parentPost
        });
        Roots.prototype.onStart.call(this);
        this.listenTo(this.parent, 'sync', this.renderIt);
        this.parent.fetch();
    },


});



module.exports = ParentPostView;