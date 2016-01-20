'use strict';

var React = require('react');
var sc = require('spatialconnect');

var Stores = React.createClass({
  getInitialState : function() {
    return {
      stores : [
        {storeid : 1, name : 'one'},
        {storeid : 2, name : 'two'}
      ],
      error : {}
    };
  },
  componentDidMount: function() {
    sc.stream.stores.subscribe(
      (data) => {
        console.log(data);
        this.setState(data);
      },
      (err) => {
        console.log(err);
        this.setState({
          error : err
        });
      },
      () => {
        this.setState({
          error : {}
        });
      }
    );
    sc.action.stores();
  },
  render: function() {
    return (
      <ul className="drawer" key="d">
        {this.state.stores.map((store,i) => {
          return (
            <li key={i}>
              {store.name}
            </li>
          );
        })}
      </ul>
    );
  }
});

module.exports = Stores;
