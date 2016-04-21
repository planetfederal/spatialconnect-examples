import React, {
  Component,
  NativeAppEventEmitter,
  PropTypes,
  NativeModules,
  ScrollView,
  StyleSheet,
  Text,
  TouchableHighlight,
  View
} from 'react-native';
import transform from 'tcomb-json-schema';
import tcomb from 'tcomb-form-native';
import api from '../utils/api';
import palette from '../style/palette';
import formtemplates from '../formtemplates';

tcomb.form.Form.i18n = {
  optional: '',
  required: ' *'
};

transform.registerType('date', tcomb.Date);
transform.registerType('time', tcomb.Date);

let Form = tcomb.form.Form;

class FormSuccess extends Component {
  render() {
    return (
      <View style={{marginTop: 65}}>
        <Text>Form Submitted Successfully.</Text>
      </View>
    );
  }
}

class SpatialConnectForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
      location: null,
      value: {}
    };
  }

  saveForm(formData) {
    this.subscription.remove();
    api.saveForm(this.props.formInfo.id, formData)
      .then(() => {
        this.props.navigator.push({
          title: '',
          component: FormSuccess
        });
      })
      .catch(() => {
        //TODO handle error submitting form
      });
  }

  onPress () {
    var value = this.refs.form.getValue();
    if (value) {
      this.saveForm(value);
    }
  }

  makeFormOptions(properties) {
    let options = { fields: {} };

    for (let prop in properties) {
      //set correct mode for data and time fields
      if (properties[prop].type == 'date') {
        options.fields[prop] = { mode: 'date' };
      }
      if (properties[prop].type == 'time') {
        options.fields[prop] = { mode: 'time' };
      }
      //set correct template for slider and counter
      if (properties[prop].mode == 'slider') {
        options.fields[prop] = {
          template: formtemplates.slider,
          config: properties[prop]
        };
      }
      if (properties[prop].mode == 'counter') {
        options.fields[prop] = {
          template: formtemplates.counter,
          config: properties[prop]
        };
      }
    }
    return options;
  }

  componentWillMount() {
    NativeModules.SCJavascript.startGPS();
    this.subscription = NativeAppEventEmitter.addListener( 'lastKnown', (location) => {
      this.setState({
        location: location
      });
    });

    let initialValues = {};

    for (let prop in this.props.formInfo.schema.properties) {
      if (this.props.formInfo.schema.properties[prop].hasOwnProperty('initialValue')) {
        initialValues[prop] = this.props.formInfo.schema.properties[prop].initialValue;
      }
    }
    this.setState({value: initialValues});
    this.TcombType = transform(this.props.formInfo.schema);
    this.options = this.makeFormOptions(this.props.formInfo.schema.properties);
  }

  componentWillUnmount() {
    this.subscription.remove();
  }

  onChange(value) {
    this.setState({value});
  }

  render() {
    let locationLabel = (
      this.state.location ?
      <Text>{this.state.location.lat}, {this.state.location.lon}</Text> :
      <View></View>
    );
    return (
      <View style={styles.container}>
        <ScrollView style={styles.scrollView}>
          <View style={styles.formName}>
            <Text style={styles.formNameText}>{this.props.formInfo.name}</Text>
          </View>
          <View style={styles.form}>
          {locationLabel}
            <Form
              ref="form"
              value={this.state.value}
              type={this.TcombType}
              options={this.options}
              onChange={this.onChange.bind(this)}
            />
            <TouchableHighlight style={styles.button} onPress={this.onPress.bind(this)} underlayColor={palette.lightblue}>
              <Text style={styles.buttonText}>Submit</Text>
            </TouchableHighlight>
          </View>
        </ScrollView>
      </View>
    );
  }
}

SpatialConnectForm.propTypes = {
  formInfo: PropTypes.object.isRequired,
  navigator: PropTypes.object.isRequired
};

var styles = StyleSheet.create({
  container: {
    flex: 1,
    marginTop: 60,
    justifyContent: 'center',
    flexDirection: 'column',
    backgroundColor: palette.gray
  },
  scrollView: {
    flex: 1
  },
  formName: {
    backgroundColor: palette.darkblue,
    paddingTop: 10,
    paddingBottom: 10,
    paddingLeft: 20,
    paddingRight: 20
  },
  formNameText: {
    color: 'white',
    fontSize: 24
  },
  form: {
    padding: 20
  },
  buttonText: {
    fontSize: 18,
    color: 'white',
    alignSelf: 'center'
  },
  button: {
    height: 36,
    backgroundColor: palette.darkblue,
    borderColor: palette.darkblue,
    borderWidth: 1,
    borderRadius: 5,
    marginBottom: 10,
    alignSelf: 'stretch',
    justifyContent: 'center'
  }
});

export default SpatialConnectForm;
