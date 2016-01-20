'use strict';
/*global ol*/

var React = require('react');
var Location = require('./location');
var GPS = require('./gps');
var ol = require('openlayers');
var sc = require('spatialconnect');

var Map = React.createClass({
  componentDidMount: function() {
    var map = this.props.map;
    var me = this.refs.map;
    var elem = React.findDOMNode(me);
    map.setTarget(elem);
  },
  addFeature:function() {
    var map = this.props.map;
    var coord = map.getView().getCenter();
    var feature; //TODO
  },
  geoSpatialQuery: function(map) {
    var extent = map.getView().calculateExtent(map.getSize());
    var f = sc.Filter().geoBBOXContains(extent);
    sc.action.geospatialQuery(f);
  },
  render: function() {
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
        <button onClick={this.geoSpatialQuery.bind(this,this.props.map)}>Reload Features</button>
        <div>
          <div ref="map" id="map"></div>
        </div>
      </div>

      </div>
    );
  }
});

module.exports = Map;
