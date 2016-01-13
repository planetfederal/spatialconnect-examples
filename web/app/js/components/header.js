'use strict';

var React = require('react');

var Header = React.createClass({

  render: function() {
    return <div className="bar bar-nav">
      <a className="icon icon-bars pull-left" onClick={this.props.onDrawerToggleClick}>
        <button>Stores</button>
      </a>
    </div>;
  }
});

module.exports = Header;
