'use strict';

var React = require('react');
var Location = require('./location');
var GPS = require('./gps');
var Parent = require('./parent');

var Panel = React.createClass({
  render : function() {
    return (
      <div className="row">
        <div className="col-xs-3">
          <Parent/>
        </div>
        <div className="col-xs-8">
          <GPS></GPS>
        </div>
      </div>
    );
  }
});

module.exports = Panel;
