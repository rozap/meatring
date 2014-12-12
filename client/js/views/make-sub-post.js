var MakePost = require('./make-post');


module.exports = MakePost.extend({
    _onSuccess: function(res) {
        this._parentView.add(res);
        this.end();
    },
});