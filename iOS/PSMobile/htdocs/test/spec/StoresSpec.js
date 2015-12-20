'use strict';
/*global describe,it,expect:false */
var sc = require('spatialconnect-js');

describe('stores',function () {
  it('have an active list',function(done){
    sc.stream.stores.subscribe(
      function (s) {
        expect(s).toBeDefined();
        done();
      },
      function (err) {
        console.log(err);
      },
      function() {
      }
    );
    sc.action.stores();
  });
  it('get store by id',function(done) {
    sc.stream.store.subscribe(
      function (s) {
        expect(s).toBeDefined();
        done();
      },function (err) {
        console.log(err);
      },
      function() {
      }
    );

    sc.stream.stores.map(function (s) {
      var stores = s.stores;
      var idx = Math.random() * (stores.length-1);
      return stores[idx];
    }).subscribe(
      function (s) {
        sc.action.store(s.storeid);
      },function (err) {
        console.error(err);
      },function () {

      }
    );
    sc.action.stores();
  });
});
