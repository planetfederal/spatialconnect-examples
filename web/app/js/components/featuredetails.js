'use strict';
/* global ol */
var React = require('react');
var sc = require('spatialconnect');

var FeatureDetails = React.createClass({
  getInitialState: function() {
    return {
      selectedFeature: null
    }
  },
  componentDidMount: function() {
    this.setState({selectedFeature: this.props.feature});
  },
  updateFeature: function(e) {
    e.preventDefault();
    sc.action.updateFeature(
      new ol.format.GeoJSON().writeFeature(this.state.selectedFeature)
    );
  },
  deleteFeature: function() {
    sc.action.deleteFeature(this.state.selectedFeature.getId());
  },
  handleChange: function(propKey, event) {
    var value = event.target.value;
    var feature = this.state.selectedFeature;
    feature.set(propKey, value);
    this.setState({selectedFeature: feature});
  },
  render: function() {
    var form;
    if (this.state.selectedFeature !== null) {
      form = <form key="details" onSubmit={this.updateFeature}>
        {this.state.selectedFeature.getKeys().map((propKey, i) => {
          return (
            <div className="form-group" key={i}>
              <label>{propKey}</label>
              <input type="text"
                onChange={this.handleChange.bind(this, propKey)}
                value={this.state.selectedFeature.get(propKey)}>
              </input>
            </div>
          );
        })}
        <input type="submit" value="Update Feature" />
        <button onClick={this.deleteFeature}>Delete Feature</button>
      </form>
    }
    return (
      <div>
        <h1>Feature details</h1>
        {form}
      </div>
    );
  }
});

module.exports = FeatureDetails;
