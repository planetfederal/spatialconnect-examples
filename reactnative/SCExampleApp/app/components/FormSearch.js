import React, {
  ActivityIndicatorIOS,
  Component,
  PropTypes,
  StyleSheet,
  Text,
  TextInput,
  TouchableHighlight,
  View
} from 'react-native';
import SpatialConnectForm from './SpatialConnectForm';
import api from '../utils/api';
import palette from '../style/palette';

class FormSearch extends Component {
  constructor(props) {
    super(props);
    this.state = {
      formID: '',
      isLoading: false,
      loaded: false
    };
  }

  handleChange(event){
    this.setState({
      formID: event.nativeEvent.text
    });
  }

  handleSubmit(){
    this.setState({
      isLoading: true
    });
    api.getForm(this.state.formID)
      .then(this.onFormLoad.bind(this))
      .catch(() => {
        this.setState({
          error: 'Unable to load form',
          isLoading: false
        });
      });
  }

  onFormLoad(res) {
    if (!res.id) {
      this.setState({
        error: 'Form Not Found',
        isLoading: false
      });
    } else {
      this.props.navigator.push({
        title: '',
        component: SpatialConnectForm,
        passProps: { formInfo: res }
      });
      this.setState({
        isLoading: false,
        error: false,
        formID: ''
      });
    }
  }

  render() {
    let showErr = (
      this.state.error ? <Text> {this.state.error} </Text> : <View></View>
    );
    return (
      <View style={styles.mainContainer}>
      <Text style={styles.title}> Enter Form ID </Text>
      <TextInput
        style={styles.searchInput}
        value={this.state.formID}
        onChange={this.handleChange.bind(this)}
        underlayColor="white" />
        <TouchableHighlight
          style={styles.button}
          onPress={this.handleSubmit.bind(this)}
          underlayColor="white">
          <Text style={styles.buttonText}> Search </Text>
        </TouchableHighlight>
        <ActivityIndicatorIOS
          animating={this.state.isLoading}
          color='#111'
          size='large'></ActivityIndicatorIOS>
        {showErr}
      </View>
    );
  }
}

FormSearch.propTypes = {
  navigator: PropTypes.object.isRequired
};

var styles = StyleSheet.create({
  mainContainer: {
    flex: 1,
    padding: 30,
    marginTop: 60,
    flexDirection: 'column',
    justifyContent: 'center',
    backgroundColor: palette.darkblue
  },
  title: {
    marginBottom: 20,
    fontSize: 25,
    textAlign: 'center',
    color: '#fff'
  },
  searchInput: {
    height: 50,
    padding: 4,
    fontSize: 23,
    borderWidth: 1,
    borderRadius: 8,
    borderColor: 'white',
    backgroundColor: palette.gray,
    color: 'black'
  },
  buttonText: {
    fontSize: 18,
    color: '#111',
    alignSelf: 'center'
  },
  button: {
    height: 45,
    flexDirection: 'row',
    backgroundColor: palette.gray,
    borderColor: 'white',
    borderWidth: 1,
    borderRadius: 8,
    marginBottom: 10,
    marginTop: 10,
    alignSelf: 'stretch',
    justifyContent: 'center'
  }
});

export default FormSearch;