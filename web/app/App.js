'use strict';
/*global ol*/
var React = require('react');
var styles = require('./js/style');
var sc = require('spatialconnect');
var sample = require('./js/sample');
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

const customStyles = {
  content : {
    top                   : '50%',
    left                  : '50%',
    right                 : 'auto',
    bottom                : 'auto',
    marginRight           : '-50%',
    transform             : 'translate(-50%, -50%)'
  }
};

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

FeatureObs.create.subscribe(
  function(n) {
    var gjFmt = new ol.format.GeoJSON();
    var geojson = gjFmt.writeFeature(n);
    sc.action.createFeature(geojson);
    vectorSource.addFeature(n);
  },
  function(err) {
    console.log(err);
  },
  function() {}
);

var App = React.createClass({
  getInitialState: function() {
    return { modalIsOpen: false };
  },

  openModal: function() {
    this.setState({modalIsOpen: true});
  },

  closeModal: function() {
    this.setState({modalIsOpen: false});
  },
  componentDidMount: function() {
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
  },
  render : function() {
    return (
      <div>
        <Tabs>
          <TabList>
            <Tab>Stores</Tab>
            <Tab>Map</Tab>
          </TabList>
          <TabPanel title='Stores'>
            <Stores/>
          </TabPanel>
          <TabPanel title='Map'>
            <button onClick={this.openModal}>Open Modal</button>
            <MapView map={map}/>
            <Modal
              isOpen={this.state.modalIsOpen}
              onRequestClose={this.closeModal}
              style={customStyles} >

              <h2>Hello</h2>
              <button onClick={this.closeModal}>close</button>
              <div>
                I am a modal
              </div>
              <form>
                <input />
                <button>
                  tab navigation
                </button>
                <button>stays</button>
                <button>inside</button>
                <button>
                  the modal
                </button>
              </form>
            </Modal>
          </TabPanel>
        </Tabs>
      </div>
    );
  }
});
ReactDOM.render(<App />,document.getElementById('app'));
