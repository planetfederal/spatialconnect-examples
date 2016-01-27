'use strict';
/*global ol*/
var React = require('react');
var styles = require('./js/style');
var sc = require('spatialconnect');
var sample = require('./js/sample');
var ReactDOM = require('react-dom');
var ReactTabs = require('react-tabs');
var ReactDOM = require('react-dom');
var Tab = ReactTabs.Tab;
var Tabs = ReactTabs.Tabs;
var TabList = ReactTabs.TabList;
var TabPanel = ReactTabs.TabPanel;
var Stores = require('./js/components/stores');
var MapView = require('./js/components/map');
var Modal = require('react-modal');
var FeatureObs = require('./js/stores/feature');
var FeatureDetails = require('./js/components/featuredetails');

var vectorSource = new ol.source.Vector({
  features: sample
});

var styleFunction = function(feature) {
  return styles[feature.getGeometry().getType()];
};

var vectorLayer = new ol.layer.Vector({
  source: vectorSource,
  style: styleFunction
});

var layers = [
  new ol.layer.Tile({
          style: 'Aerial',
          source: new ol.source.MapQuest({layer: 'osm'})
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

FeatureObs.create.subscribe(
  function(n) {
    var gjFmt = new ol.format.GeoJSON();
    var geojson = gjFmt.writeFeature(n);
    sc.stream.createFeature.subscribe(
      function(f) {
        var gj = gjFmt.readFeature(f);
        vectorSource.addFeature(gj);
      }
    );
    sc.action.createFeature(geojson,'a5d93796-5026-46f7-a2ff-e5dec85heh6b', 'point_features');
  },
  function(err) {
    console.log(err);
  },
  function() {}
);

var App = React.createClass({
  getInitialState: function() {
    return {
      modalIsOpen: false,
      selectedFeature: null
    };
  },

  openModal: function() {
    this.setState({modalIsOpen: true});
  },

  closeModal: function() {
    this.setState({modalIsOpen: false});
  },
  componentDidMount: function() {
    var that = this;
    sc.stream.spatialQuery.subscribe(
      (data) => {
        var gj = (new ol.format.GeoJSON()).readFeature(data);
        vectorSource.addFeature(gj);
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
    FeatureObs.modalClose.subscribe(
      () => that.setState({modalIsOpen:false}),
      () => {},
      () => {}
    );
    map.on('singleclick', function(evt) {
      map.forEachFeatureAtPixel(evt.pixel,
        function(feature) {
          if (feature) {
            that.setState({
              selectedFeature: feature
            });
            that.openModal();
          }
        }
      );
    });
    map.on('doubleclick', function() {}); //swallow doubleclick for ios webview
    FeatureObs.delete.subscribe(
      function(deleteFeatureId) {
        var feature = vectorSource.getFeatureById(deleteFeatureId)
        vectorSource.removeFeature(feature);
        that.closeModal();
      },
      function(err) {
        console.log(err);
      },
      function() {}
    );
  },
  render : function() {
    var details;
    if (this.state.selectedFeature) {
      details = <FeatureDetails feature={this.state.selectedFeature} />;
    } else {
      details = null;
    }
    return (
      <div>
        <Tabs>
          <TabList>
            <Tab>Map</Tab>
            <Tab>Stores</Tab>
          </TabList>
          <TabPanel title='Map'>
            <MapView map={map}/>
            <Modal isOpen={this.state.modalIsOpen}>
              <button onClick={this.closeModal}>Close Modal</button>
              {details}
            </Modal>
          </TabPanel>
          <TabPanel title='Stores'>
            <Stores/>
          </TabPanel>
        </Tabs>
      </div>
    );
  }
});
ReactDOM.render(<App />,document.getElementById('app'));
