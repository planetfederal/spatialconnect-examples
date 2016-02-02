'use strict';

var Rx = require('rx');

var returnObject = {};

returnObject.create = new Rx.Subject();
returnObject.update = new Rx.Subject();
returnObject.delete = new Rx.Subject();
returnObject.query = new Rx.Subject();
returnObject.modalClose = new Rx.Subject();

module.exports = returnObject;
