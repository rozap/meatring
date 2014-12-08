var Backbone = require('backbone');

module.exports = Backbone.Model.extend({
    idAttribute: 'key',
    url: function() {
        return '/api/item' + (this.get('key') ? '/' + this.get('key') : '');
    },

    parse: function(resp) {
        return {
            key: this.get('key'),
            data: resp
        };
    }

});