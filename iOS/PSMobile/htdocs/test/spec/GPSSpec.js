'use strict';
/*global describe,it,expect:false */
var sc = require('spatialconnect-js');

describe('GPS',function () {
  it('Turn On',function(done){
    sc.stream.lastKnownLocation.subscribe(
      function (d) {
        expect(d).toBeDefined();
        done();
      },function (err) {
        console.log(err);
      },function() {
        console.log('done');
      }
    );
    sc.action.enableGPS();
  });

  it('Turn Off',function (done) {
    sc.action.disableGPS();
    sc.stream.lastKnownLocation.subscribe(
      function (d) {
        expect(d).toBeDefined();
        done();
      }
    );
  });

  it('Get Last Known Location', function (done) {
    sc.stream.lastKnownLocation.subscribe(
      function (d) {
        expect(d).toBeDefined();
        done();
      }
    );
  });
});
