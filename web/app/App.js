'use strict';
/*global ol*/
var React = require('react');
var Drawer = require('./js/components/drawer');
var styles = require('./js/style');
var sc = require('./SpatialConnect');
var sample = require('./js/sample');
var Panel = require('./js/components/panel');
var Tabs = require('react-simpletabs');

var vectorSource = new ol.source.Vector({
  features: sample
});
vectorSource.addFeature(new ol.Feature(new ol.geom.Circle([20, 20], 10)));

var styleFunction = function(feature) {
  return styles[feature.getGeometry().getType()];
};

var vectorLayer = new ol.layer.Vector({
  source: vectorSource,
  style: styleFunction
});

var layers = [
  new ol.layer.Tile({
    source: new ol.source.TileWMS({
      url: 'http://demo.boundlessgeo.com/geoserver/wms',
      params: {
        'LAYERS': 'ne:NE1_HR_LC_SR_W_DR'
      }
    })
  }),
  vectorLayer
];

var map = new ol.Map({
  layers: layers,
  view: new ol.View({
    projection: 'EPSG:4326',
    center: [30, 30],
    zoom: 2
  })
});

sc.stream.spatialQuery.subscribe(
  (data) => {
    var gj = (new ol.format.GeoJSON()).readFeatures(data);
    vectorSource.addFeatures(gj);
  },
  (err) => {
    this.setState({
      error : err
    });
  },
  () => {
    this.setState({
      error : {}
    });
  }
);

var App = React.createClass({
  render : function() {
    return (
      <Tabs>
        <Tabs.Panel title='Stores'>
          <h2>Stores</h2>
        </Tabs.Panel>
        <Tabs.Panel title='Map'>
          <Panel map={map}/>
        </Tabs.Panel>
      </Tabs>
    );
  }
});
React.render(<App />,document.getElementById('app'));
