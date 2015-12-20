'use strict';

var React = require('react');
var Location = require('./location');
var SC = require('spatialconnect-js');

var GPS = React.createClass({
  getInitialState : function() {
    return {
      checked : false
    };
  },
  gpsClicked : function(event) {
    var checked = event.target.checked;
    if (checked) {
      SC.action.enableGPS();
    } else {
      SC.action.disableGPS();
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
