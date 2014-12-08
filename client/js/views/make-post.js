var _ = require('underscore');
var View = require('./view');
var MakePostTemplate = require('../../templates/make-post.html');
var MakePost = require('./make-post');
var Webrtc2images = require('webrtc2images');
var Post = require('../models/post');

module.exports = View.extend({

    template: _.template(MakePostTemplate),

    events: {
        'click .ok': 'submitPost',
        'click .nvm': 'end'
    },



    onStart: function() {
        if (!this.$el) throw new Error("Make post needs an el");
        if (!this.parentPost) throw new Error("what am I making the post on? needs a parent or root if none");
        this.render();
    },

    post: function() {
        this.rtc2images = new Webrtc2images({
            width: 320,
            height: 180,
            frames: 10,
            type: 'image/jpeg',
            quality: 0.4,
            interval: 200
        });

        this.rtc2images.startVideo(function(err) {
            if (err) {
                console.log(err);
            }
        });

    },


    submitPost: function() {
        var text = this.$el.find('textarea').val();
        this.rtc2images.recordVideo(function(err, frames) {
            if (err) {
                console.log(err);
            } else {
                console.log(frames);

                var post = new Post({
                    data: {
                        frames: frames,
                        text: text,

                    },
                    meta: {
                        parent: this.parentPost
                    }
                });

                post.save();
            }
        });
    }



});