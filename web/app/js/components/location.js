'use strict';

var React = require('react');
var sc = require('spatialconnect-js');

var Location = React.createClass({
  getInitialState: function() {
    return {
      latitude : 0.0,
      longitude : 0.0,
      altitude : 0.0
    };
  },
  componentDidMount: function() {
    sc.stream.lastKnownLocation.subscribe(
      (data) => this.setState(data),
      (err) => err,
      () => console.log('Completed')
    );
  },
  render: function() {
    return (
      <span> {this.state.longitude}, {this.state.latitude}</span>
    );
  }
});

module.exports = Location;
