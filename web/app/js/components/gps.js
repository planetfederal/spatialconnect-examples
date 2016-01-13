'use strict';

var React = require('react');
var sc = require('./../../SpatialConnect');
var Location = require('./location');

var GPS = React.createClass({
  getInitialState : function() {
    return {
      checked : false
    };
  },
  gpsClicked : function(event) {
    var checked = event.target.checked;
    if (checked) {
      sc.action.enableGPS();
    } else {
      sc.action.disableGPS();
    }
    this.setState({checked : checked});
  },
  render: function() {
    return (
      <div>
        Location <input type="checkbox" checked={this.state.checked} onChange={this.gpsClicked}></input>
        {this.state.checked ? <Location/> : null}
      </div>
    );
  }

});

module.exports = GPS;
