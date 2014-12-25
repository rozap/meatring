var _ = require('underscore');
var Backbone = require('backbone');

/*
    This just wraps a socket in a event emitter, which is the piece
    the views have access to, not the underlying socket
 */

var Dispatcher = function(onSetup) {

    this._emitter = _.clone(Backbone.Events);
    this._onSetup = onSetup;
    this._sock = new WebSocket('ws://' + window.location.host + '/websocket');
    this._sock.onopen = this.onopen.bind(this);
    this._sock.onerror = this.onerror.bind(this);
    this._sock.onmessage = this.onmessage.bind(this);

    this._emitter.on('dht', this._dispatchToDht.bind(this));
};

Dispatcher.prototype = {

    emitter: function() {
        return this._emitter;
    },

    onopen: function() {
        console.log("Socket opened");
        this._onSetup(null, this);
    },

    onerror: function(err) {
        console.warn("socket error", err);
        this._onSetup(err);
    },

    onmessage: function(e) {
        console.log("sock message", e.data);
    },

    _dispatchToDht: function(message) {
        console.log("Dispatch to dht", message);
        this._sock.send(message);
    }

};



module.exports = Dispatcher;