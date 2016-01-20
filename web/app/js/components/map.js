'use strict';
/*global ol*/

var React = require('react');
var Location = require('./location');
var GPS = require('./gps');
var ol = require('openlayers');
var sc = require('spatialconnect');

class Map extends React.Component {
  componentDidMount() {
    var map = this.props.map;
    var me = this.refs.map;
    var elem = React.findDOMNode(me);
    map.setTarget(elem);
  }
  addFeature() {
    var map = this.props.map;
    var coord = map.getView().getCenter();
    var feature; //TODO
    featureObs.onNext({action:ADD,value:feature});
  }
  render() {
    return (
      <div>
        <div className="row">
          <div className="col-xs-2">
            <GPS></GPS>
          </div>
          <div className="col-xs-2">
            <button onClick={this.addFeature}>
              Add Feature
            </button>
          </div>
        </div>
      <div className="row">
        <div>
          <div ref="map" id="map"></div>
        </div>
      </div>

      </div>
    );
  }
}

module.exports = Map;
