'use strict';
/*global describe,it,expect:false */
var sc = require('spatialconnect-js');
var ol = require('ol');

describe('Feature',function () {
  it('Create',function(){
    var geometry = new ol.Feature(new ol.geom.Point([5e6,5e6],1e6));
    var fObj = sc.gfeature(geometry,storeId,spatialfeature);
    sc.action.createFeature(fObj);
  });

  it('Update', function () {
    var fObj = sc.gfeature(geometry,storeId);
  });

  it('Delete', function () {

  });
});
