'use strict';

var React = require('react');
var sc = require('spatialconnect');

var FeatureDetails = React.createClass({
  componentDidMount: function() {
    this.setState({selectedFeature: this.props.feature});
  },
  updateFeature: function(e) {
    e.preventDefault();
    sc.action.updateFeature(
      new ol.format.GeoJSON().writeFeature(this.state.selectedFeature)
    );
  },
  handleChange: function(event) {
    // TODO: maybe use react to select?
    var key = event.target.parentElement.childNodes[0].innerHTML;
    var value = event.target.value;
    var feature = this.state.selectedFeature;
    feature.set(key, value);
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
                  onChange={this.handleChange}
                  value={this.props.feature.get(propKey)}>
                </input>
              </div>
            );
          })}
          <input type="submit" value="Update Feature" />
        </form>
      </div>
    );
  }
});

module.exports = FeatureDetails;
