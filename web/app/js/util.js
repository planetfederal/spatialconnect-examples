'use strict';

var Base64 = require('js-base64').Base64;
var _ = require('lodash');

var returnObject = {};

returnObject.keyToArr = function(key) {
  return _.map(key.split('.'),function(k) {
    return Base64.decode(k);
  });
};

module.exports = returnObject;
