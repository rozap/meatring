var _ = require('underscore');
var View = require('./view');
var MakePostTemplate = require('../../templates/make-post.html');
var MakePost = require('./make-post');
var Webrtc2images = require('webrtc2images');
var Whammy = require('whammy');
var Post = require('../models/post');
var async = require('async');

module.exports = View.extend({

    template: _.template(MakePostTemplate),

    events: {
        'click .ok': 'submitPost',
        'click .nvm': 'end'
    },

    _width: 160,
    _height: 120,
    _frames: 30,
    _interval: 120,



    onStart: function() {
        if (!this.$el) throw new Error("Make post needs an el");
        if (!this.parentPost) throw new Error("what am I making the post on? needs a parent or root if none");
        this.render();
    },

    fps: function() {
        //interval can't be less than 100 or weird shit starts happening...UGH
        // console.log(Math.floor(1000 / this._interval), 'fps');
        return 20
    },

    post: function() {
        this.rtc2images = new Webrtc2images({
            width: this._width,
            height: this._height,
            frames: this._frames,
            type: 'image/jpeg',
            quality: 0.6,
            interval: this._interval
        });

        this.rtc2images.startVideo(function(err) {
            if (err) {
                console.log(err);
            }
        });

    },

    _onSuccess: function(res) {
        console.log(res);
    },

    _onError: function() {
        console.warn('aw shit');
    },


    _createPost: function(url) {
        var text = this.$el.find('textarea').val();
        new Post({
            data: {
                video: url,
                text: text
            },
            meta: {
                parentPost: this.parentPost
            }
        }).save().then(this._onSuccess, this._onError);
    },

    _framesToWebm: function(frames) {
        var encoder = new Whammy.Video(this.fps());
        var can = document.createElement('canvas');
        var image = new Image(this._width, this._height);
        can.width = this._width;
        can.height = this._height;


        async.mapSeries(frames, function(frame, cb) {
            var ctx = can.getContext('2d');
            image.onload = function() {
                ctx.drawImage(image, 0, 0, this._width, this._height)

                encoder.add(ctx);

                cb();
            }.bind(this);
            image.src = frame;
        }.bind(this), function() {
            var res = encoder.compile();
            var fr = new FileReader()

            fr.onloadend = function() {
                this._createPost(fr.result);

            }.bind(this);
            fr.readAsDataURL(res);
        }.bind(this))

    },


    submitPost: function() {
        this.rtc2images.recordVideo(function(err, frames) {
            if (err) {
                console.log(err);
                return;
            }
            console.log(frames);
            this._framesToWebm(frames)

        }.bind(this));
    }



});