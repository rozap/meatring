var _ = require('underscore');
var View = require('./view');
var Roots = require('./roots');
var Post = require('../models/post');
var PostTemplate = require('../../templates/post.html');



var SubPostView = Roots.extend({
    include: ['parent', 'posts', 'parentPost'],
    template: _.template(PostTemplate),

    onFetched: function() {
        this.render();
        this.posts.each(function(post) {
            this.spawn('subPost' + post.get('key'), new SubPostView({
                app: this.app,
                parentPost: post.get('key'),
                parent: post,
                el: '#sub-' + post.get('key') + '-posts'
            }));
        }.bind(this));
    }

});


var ParentPostView = SubPostView.extend({



    onStart: function() {
        this.parent = new Post({
            key: this.parentPost
        });
        Roots.prototype.onStart.call(this);
        this.listenTo(this.parent, 'sync', this.renderIt);
        this.parent.fetch();
    },


});



module.exports = ParentPostView;