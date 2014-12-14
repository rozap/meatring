var _ = require('underscore');
var View = require('./view');
var MakePostTemplate = require('../../templates/make-post.html');
var MakePost = require('./make-post');
var Webrtc2images = require('webrtc2images');
var Whammy = require('whammy');
var Post = require('../models/post');
var async = require('async');
var ProgressView = require('./progress');

module.exports = View.extend({
    _name : 'MakePost',
    template: _.template(MakePostTemplate),
    rtcError: false,
    include: ['rtcError'],
    _width: 180,
    _height: 140,
    _frames: 20,
    _interval: 200,
    _fps: 15,


    onStart: function() {
        if (!this.$el) throw new Error("Make post needs an el");
        if (!this.parentPost) throw new Error("what am I making the post on? needs a parent or root if none");
        this.listenTo(this.app.dispatcher, 'MakePost.start', this.end);
        this.render();
    },

    post: function() {
        if (this.rtcError) return;
        this.rtc2images = new Webrtc2images({
            width: this._width,
            height: this._height,
            frames: this._frames,
            type: 'image/jpeg',
            quality: 0.6,
            interval: this._interval
        });

        this.rtc2images.startVideo(function(err) {
            if (err && !this.rtcError) {
                this.set('rtcError', err.message || err.name || err);
                return;
            } else if (!err) {
                this.rtcError = false;
                var view = this.spawn(new ProgressView({
                    app: this.app,
                    el: this.$el.find('.controls-view')
                }));
                this.listenTo(view, 'end', this.end);
            }
        }.bind(this));
    },

    _onSuccess: function(res) {
        this.app.router.navigate('post/' + res, {
            trigger: true
        });
    },

    _onError: function() {},


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
        }).save().then(this._onSuccess.bind(this), this._onError.bind(this));
    },

    _framesToWebm: function(frames) {
        var encoder = new Whammy.Video(this._fps);
        var can = document.createElement('canvas');
        var image = new Image(this._width, this._height);
        can.width = this._width;
        can.height = this._height;


        async.mapSeries(frames, function(frame, cb) {
            var ctx = can.getContext('2d');
            this.getView('ControlsView').add(50 / this._frames, 'encoding');

            image.onload = function() {
                ctx.drawImage(image, 0, 0, this._width, this._height);
                encoder.add(ctx);
                cb();
            }.bind(this);
            image.src = frame;
        }.bind(this), function() {
            var res = encoder.compile();
            var fr = new FileReader();

            fr.onloadend = function() {
                this._createPost(fr.result);

            }.bind(this);
            fr.readAsDataURL(res);
        }.bind(this));

    },


    showRecordProgress: function() {
        var update = function() {
            if (!this.getView('ControlsView')) return;
            this.getView('ControlsView').add(50 / this._frames, 'recording');
            setTimeout(update, this._interval);
        }.bind(this);

        setTimeout(update, this._interval);

    },


    submitPost: function() {
        this.showRecordProgress();
        this.rtc2images.recordVideo(function(err, frames) {
            if (err) {
                return;
            }
            this._framesToWebm(frames);

        }.bind(this));
    }



});