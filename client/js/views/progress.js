var _ = require('underscore');
var View = require('./view');
var ProgressTemplate = require('../../templates/progress.html');

module.exports = View.extend({
    _name : 'ControlsView',
    template: _.template(ProgressTemplate),
    include: ['prog', 'isInProgress', 'state'],

    events: {
        'click .ok': 'submitPost',
        'click .nvm': 'end'
    },

    _isInProgress: false,
    
    prog: 5,

    onStart: function() {
        // console.log(this.template);
        this.render();
    },

    add : function(d, state) {
        this.state = state;
        this.set('prog', Math.min(this.prog + d, 100));
    },

    submitPost: function() {
        this._isInProgress = true;
        this.render();
        console.log("submit..")
        this._parentView.submitPost();
    },

    isInProgress:function() {
        return this._isInProgress;
    }

});