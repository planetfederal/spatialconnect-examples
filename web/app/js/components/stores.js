'use strict';

var React = require('react');
var sc = require('spatialconnect-js');

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
    //sc.action.stores(); //TODO
  },
  loadStoresClicked : function() {
    sc.action.stores();
  },
  spatialQueryStore : function(id) {
    sc.action.spatialQuery(id);
  },
  render: function() {
    if (!this.props.open) {
      return <ul className="drawer" key="d"/>;
    }
    return (
      <ul className="drawer" key="d">
        {this.state.stores.map((store,i) => {
          return (
            <li key={i}>
              {store.name}
              <button onClick={this.spatialQueryStore.bind(this,store.storeid)}>Load</button>
            </li>
          );
        })}
      </ul>
    );
  }
});

module.exports = Stores;
