'use strict';

var React = require('react');

var Menu = React.createClass({
  getInitialState: function() {
    return {
      visible : false
    };
  },
  show : function() {
    this.setState({visible:true});
    document.addEventListener('click',this.hide.bind(this));
  },
  hide : function() {
    document.removeEventListner('click',this.hide.bind(this));
    this.setState({visible:false});
  },
  render: function() {
    return (
      <div className='menu'>
        <div className={(this.state.visible ? 'visible ' : '') + this.props.alignment}>
          {this.props.children}
        </div>
      </div>
    );
  }

});

module.exports = Menu;
