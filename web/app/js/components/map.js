'use strict';

var React = require('react');
var Location = require('./location');
var GPS = require('./gps');
var sc = require('spatialconnect-js');

var Map = React.createClass({
  componentDidMount: function() {
    var map = this.props.map;
    var me = this.refs.map;
    var elem = React.findDOMNode(me);
    map.setTarget(elem);
  },
  geoSpatialQuery: function(map) {
    var extent = map.getView().calculateExtent(map.getSize());
    var f = sc.Filter().geoBBOXContains(extent);
    sc.action.geospatialQuery(f);
  },
  render: function() {
    return (
      <div className="row">
        <div className="col-xs-8">
          <GPS></GPS>
        </div>
        <button onClick={this.geoSpatialQuery.bind(this,this.props.map)}>Reload Features</button>
        <div>
          <div ref="map" id="map"></div>
        </div>
      </div>
    );
  }
});

module.exports = Map;
