'use strict';

var React = require('react');
var sc = require('spatialconnect');
var Base64 = require('js-base64').Base64;

var FeatureDetails = React.createClass({
  componentDidMount: function() {
    this.setState({selectedFeature: this.props.feature});
  },
  updateFeature: function(e) {
    e.preventDefault();
    var decodedFeatureId = this.state.selectedFeature.getId().split('.').map(function(x){return Base64.decode(x)})[2]
    this.state.selectedFeature.setId(decodedFeatureId);
    sc.action.updateFeature(
      new ol.format.GeoJSON().writeFeature(this.state.selectedFeature)
    );
  },
  deleteFeature: function() {
    var decodedFeatureId = this.state.selectedFeature.getId().split('.').map(function(x){return Base64.decode(x)})[2]
    sc.action.deleteFeature(decodedFeatureId);
  },
  handleChange: function(propKey, event) {
    var value = event.target.value;
    var feature = this.state.selectedFeature;
    feature.set(propKey, value);
    this.setState({selectedFeature: feature});
  },
  render: function() {
    return (
      <div>
        <h1>Feature details</h1>
        <form key="details" onSubmit={this.updateFeature}>
          {this.props.feature.getKeys().map((propKey, i) => {
            return (
              <div className="form-group" key={i}>
                <label>{propKey}</label>
                <input type="text"
                  onChange={this.handleChange.bind(this, propKey)}
                  value={this.props.feature.get(propKey)}>
                </input>
              </div>
            );
          })}
          <input type="submit" value="Update Feature" />
          <button onClick={this.deleteFeature}>Delete Feature</button>
        </form>
      </div>
    );
  }
});

module.exports = FeatureDetails;
