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
vectorSource.addFeature(new ol.format.GeoJSON().readFeature({"type":"Feature","id":"1234.point_features.19","created":"2016-01-21T13:37:53","bbox":[-72.2382185237858,18.224075396766597,-72.2382185237858,18.224075396766597],"geometry":{"type":"Point","coordinates":[-72.2382185237858,18.224075396766597]},"properties":{"cpyrt_note":"Â© 2010. Her Majesty the Queen in Right of Canada.","fcode":"BA050","upd_info":"N_A","src_info":"World View1","ale_eval":998,"ace":25.0,"featureid":"PBA050.8","src_date":"2008-06-26","ale":-32765.0,"upd_name":998,"src_name":110,"tier_note":"N_A","id":19,"nfi":"N_A","uid":"1dd8cca8-feeb-4b70-9b59-942ddd7d1780","zval_type":3,"smc":88,"nam":"UNK","ace_eval":15,"txt":"N_A","nfn":"N_A","acc":1,"upd_date":"N_A"},"key":{"featureId":"1234.point_features.19","layerId":"point_features","storeId":"1234"}}))

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
    sc.action.createFeature(geojson,'a5d93796-5026-46f7-a2ff-e5dec85heh6b');
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
