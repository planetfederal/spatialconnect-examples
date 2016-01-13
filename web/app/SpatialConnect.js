'use strict';
/*global WebViewJavascriptBridge*/
var Rx = require('rx');
var SpatialConnect = (function(){
  var sc = {};

  var connectWebViewJavascriptBridge = function(callback) {
    console.log('loading bridge');
    if (window.WebViewJavascriptBridge) {
      console.log('one');
      callback(WebViewJavascriptBridge);
    } else {
      console.log('two');
      document.addEventListener('WebViewJavascriptBridgeReady', function() {
        console.log('three');
        callback(WebViewJavascriptBridge);
      }, false);
    }
  };

  sc.stream = {};
  sc.stream.lastKnownLocation = new Rx.Subject();
  sc.stream.spatialQuery = new Rx.Subject();
  sc.stream.stores = new Rx.Subject();

  connectWebViewJavascriptBridge(function(bridge) {
    bridge.init(function(message, responseCallback) {
      var data = { 'Javascript Responds':'Wee!' };
      responseCallback(data);
    });
    bridge.registerHandler('lastKnownLocation',(data) => sc.stream.lastKnownLocation.onNext(data));
    bridge.registerHandler('spatialQuery',(data) => sc.stream.spatialQuery.onNext(data));
    bridge.registerHandler('storesList',(data) => sc.stream.stores.onNext(data));
  });

  sc.action = {};
  sc.action.disableGPS = () => window.WebViewJavascriptBridge.send({action:'gps',value:0});
  sc.action.enableGPS = () => window.WebViewJavascriptBridge.send({action:'gps',value:1});
  sc.action.stores = () => window.WebViewJavascriptBridge.send({action:'stores'});
  sc.action.spatialQuery = (storeid) => window.WebViewJavascriptBridge.send(
    {
      action : 'spatialQuery',
      value : storeid === undefined ? 'allstores' : storeid
    }
  );

  return sc;
})();

module.exports = SpatialConnect;
