'use strict';

var React = require('react');
var Location = require('./location');
var GPS = require('./gps');
var Parent = require('./parent');

class Panel extends React.Component {
  componentDidMount() {
    var map = this.props.map;
    var me = this.refs.map;
    var elem = React.findDOMNode(me);
    map.setTarget(elem);
  }
  render() {
    return (
      <div className="row">
        <div className="col-xs-3">
          <Parent/>
        </div>
        <div className="col-xs-8">
          <GPS></GPS>
        </div>
        <div>
          <div ref="map" id="map"></div>
        </div>
      </div>
    );
  }
}

module.exports = Panel;
