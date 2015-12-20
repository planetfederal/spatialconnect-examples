'use strict';
var React = require('react/addons');
var Stores = require('./stores');
var GPS = require('./gps');

var ReactCSSTransitionGroup = React.addons.CSSTransitionGroup;

var Drawer = React.createClass({
  getInitialState: function() {
    return {
      stores : [
        {storeid : 1, name : 'one'},
        {storeid : 2, name : 'two'}
      ]
    };
  },
  render: function() {
    var items = [];
    if (this.props.open) {
      items = (
        <ul className="drawer" key="d">
          {this.state.stores.map(function(store, i) {
              return (
                <li key={i} >
                  {store.name}
                </li>
              );
            }.bind(this))
          }
        </ul>
      );
    }

    return (
      <ReactCSSTransitionGroup transitionName="drawer">
        <Stores open={this.props.open}/>
      </ReactCSSTransitionGroup>
    );
  }
});

module.exports = Drawer;
