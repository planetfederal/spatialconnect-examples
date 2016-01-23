'use strict';
/* global ol */
var React = require('react');
var sc = require('spatialconnect');
var FeatureDetails = require('./featuredetails');
var Modal = require('react-modal');
var Base64 = require('js-base64').Base64;
var _ = require('lodash');

var keyToArr = function(key) {
  return _.map(key.split('.'),function(k) {
    return Base64.decode(k);
  });
};

var Popup = React.createClass({
  getInitialState: function() {
    return {
      selectedFeature: null,
      modalIsOpen: false
    };
  },
  componentDidMount: function() {
    var that = this;
    var map = this.props.map;
    var element = document.getElementById('popup');
    var popup = new ol.Overlay({
      element: element,
      positioning: 'bottom-center',
      stopEvent: false
    });
    map.addOverlay(popup);
    map.on('click', function(evt) {
      var feature = map.forEachFeatureAtPixel(evt.pixel,
          function(feature, layer) {
            return feature;
          });
      if (feature) {
        that.setState({
          selectedFeature: feature
        });
        popup.setPosition(evt.coordinate);
        $(element).popover({
          'placement': 'top',
          'html': true,
          'content': document.getElementById('popup-content')
        });
        $(element).popover('show');
      } else {
        $(element).popover('hide');
      }
    });
  },
  showDetails: function() {
    this.setState({
      modalIsOpen: true
    });
  },
  closeModal: function() {
    this.setState({
      modalIsOpen: false
    });
  },
  render: function() {
    var displayId = this.state.selectedFeature ?
        keyToArr(this.state.selectedFeature.getId())[2] : 'None';
    return (
      <div>
        <Modal isOpen={this.state.modalIsOpen}>
          <button onClick={this.closeModal}>Close Modal</button>
          <FeatureDetails feature={this.state.selectedFeature} />
        </Modal>
        <div id="popup" className="ol-popup">
          <a href="#" id="popup-closer" className="ol-popup-closer"></a>
          <div id="popup-content" onClick={this.showDetails}>
            <span>
              Feature Id: {displayId}
            </span>
          </div>
        </div>
      </div>
    );
  }
});

module.exports = Popup;
