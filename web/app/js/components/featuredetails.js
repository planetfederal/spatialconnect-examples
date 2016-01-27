'use strict';
/* global ol */
var React = require('react');
var sc = require('spatialconnect');
var FeatureObs = require('../stores/feature');
var Util = require('../util');

var FeatureDetails = React.createClass({
  getInitialState: function() {
    return {
      selectedFeature: null
    };
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
    FeatureObs.delete.onNext(this.state.selectedFeature.getId());
  },
  handleChange: function(propKey, event) {
    var value = event.target.value;
    var feature = this.state.selectedFeature;
    feature.set(propKey, value);
    this.setState({selectedFeature: feature});
  },
  render: function() {
    var details;
    if (this.state.selectedFeature !== null) {
      var key = Util.keyToArr(this.state.selectedFeature.getId());
      details = <div>
        <div>
          Store ID:{key[0]}
        </div>
        <div>
          Layer ID:{key[1]}
        </div>
        <div>
          Feature ID:{key[2]}
        </div>
        <form key="details" onSubmit={this.updateFeature}>
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
          <input type="submit" value="Update" />
          <button type="button" onClick={this.deleteFeature}>Delete</button>
          <button type="button" onClick={this.closeModal}>Close</button>
        </form>
      </div>;
    }
    return (
      <div>
        <h1>Feature details</h1>
        {details}
      </div>
    );
  }
});

module.exports = FeatureDetails;
