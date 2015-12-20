'use strict';

var Drawer = require('./drawer');
var Header = require('./header');
var React = require('react');

var Parent = React.createClass({

  getInitialState: function() {
    return {
      drawerOpen: false
    };
  },
  handleDrawerToggleClick: function(){
    this.setState({
      drawerOpen: !this.state.drawerOpen
    });
  },

  render: function() {
    return (
      <div>
        <Header onDrawerToggleClick={this.handleDrawerToggleClick}/>
        <Drawer open={this.state.drawerOpen}/>
      </div>
    );
  }
});

module.exports = Parent;
