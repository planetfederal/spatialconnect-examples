'use strict';

var React = require('react');

var MenuItem = React.createClass({
  navigate: function(hash) {
		window.location.hash = hash;
	},
	render: function() {
		return <div className="menu-item" onClick={this.navigate.bind(this, this.props.hash)}>{this.props.children}</div>;
	}
});

module.exports = MenuItem;
