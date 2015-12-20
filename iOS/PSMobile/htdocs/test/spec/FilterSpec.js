'use strict';
/* global it:false*/
/* global expect:false*/
var SC = require('spatialconnect-js');
var filter = SC.Filter;
var describe = window.describe;

var isArray = function (a) {
  return Array.isArray(a);
};

var isString = function(s) {
  return typeof s === 'string';
};

describe('filter',function() {
  describe('geoBBOXContains',function () {
    var f = filter().geoBBOXContains(
      [-180,-90,180,90]
    );
    var val = f.value();
    it('to be an array',function () {
      expect(isArray(val.$geocontains)).toBe(true);
    });
  });

  describe('geoBBOXDisjoint',function () {
    var f = filter().geoBBOXContains(
      [-180,-90,180,90]
    );
    var val = f.value();
    it('to be an array',function () {
      expect(isArray(val.$geocontains)).toBe(true);
    });
  });

  describe('greaterThan',function () {
    var f = filter().greaterThan('foo');
    var val = f.value();
    it('to be a string',function () {
      expect(isString(val.$gt)).toBe(true);
    });
  });

  describe('greaterThanOrEqual',function () {
    var f = filter().greaterThanOrEqual('foo');
    var val = f.value();
    it('to be a string',function () {
      expect(isString(val.$gte)).toBe(true);
    });
  });

  describe('lessThan',function () {
    var f = filter().lessThan('foo');
    var val = f.value();
    it('to be a string',function () {
      expect(isString(val.$lt)).toBe(true);
    });
  });

  describe('lessThanOrEqual',function() {
    var f = filter().lessThanOrEqual('foo');
    var val = f.value();
    it('to be a string',function () {
      expect(isString(val.$lte)).toBe(true);
    });
  });

  describe('equal',function () {
    var f = filter().equal('foo');
    var val = f.value();
    it('to be a string',function () {
      expect(isString(val.$e)).toBe(true);
    });
  });

  describe('notEqual',function () {
    var f = filter().notEqual('foo');
    var val = f.value();
    it('to be a string',function () {
      expect(isString(val.$ne)).toBe(true);
    });
  });

  describe('between',function () {
    var f = filter().between('foo','foo2');
    var val = f.value();
    it('to be an object',function () {
      expect(val.$between).toBeDefined();
    });
  });

  describe('notBetween',function() {
    var f = filter().notBetween('foo','foo2');
    var val = f.value();
    it('to be an object',function () {
      expect(val.$notbetween).toBeDefined();
    });
  });

  describe('in',function () {
    var f = filter().in(
      [-180,-90,180,90]
    );
    var val = f.value();
    it('to be an array',function () {
      expect(isArray(val.$in)).toBe(true);
    });
  });

  describe('notIn',function () {
    var f = filter().notIn(
      [-180,-90,180,90]
    );
    var val = f.value();
    it('to be an array',function () {
      expect(isArray(val.$notin)).toBe(true);
    });
  });

  describe('like',function () {
    var f = filter().like('foo');
    var val = f.value();
    it('to be a string',function () {
      expect(isString(val.$like)).toBe(true);
    });
  });

  describe('notLike',function () {
    var f = filter().notLike('foo');
    var val = f.value();
    it('to be a string',function () {
      expect(isString(val.$notlike)).toBe(true);
    });
  });
});
