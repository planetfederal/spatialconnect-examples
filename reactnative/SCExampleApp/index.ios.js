/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 */

import React, {
  AppRegistry,
  Component,
  Navigator,
  StyleSheet,
  Text,
  TouchableHighlight
} from 'react-native';

import FormSearch from './app/components/FormSearch';
import palette from './app/style/palette';

var NavigationBarRouteMapper = {
  LeftButton(route, navigator, index, navState) {
    if(index > 0) {
      return (
        <TouchableHighlight
          underlayColor="transparent"
          onPress={() => { if (index > 0) { navigator.pop() } }}>
          <Text style={ styles.leftNavButtonText }>Back</Text>
        </TouchableHighlight>);
    }
    else {
      return null;
    }
  },
  RightButton(route, navigator, index, navState) {
    if (route.onPress) return (
      <TouchableHighlight
         onPress={ () => route.onPress() }>
         <Text style={ styles.rightNavButtonText }>
              { route.rightText || 'Right Button' }
         </Text>
       </TouchableHighlight>);
  },
  Title(route, navigator, index, navState) {
    return <Text style={ styles.title }>Spatial Connect</Text>;
  }
};

class SCExampleApp extends Component {
  renderScene(route, navigator) {
    return React.createElement(route.component, { ...this.props, ...route.passProps, route, navigator } );
  }

  render() {
    return (
      <Navigator
        style={styles.container}
        initialRoute={{component: FormSearch}}
        renderScene={this.renderScene}
        navigationBar={
          <Navigator.NavigationBar
            style={ styles.nav }
            routeMapper={ NavigationBarRouteMapper } />
        }
     />
    );
  }
}

var styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    backgroundColor: palette.gray
  },
  nav: {
    height: 60,
    backgroundColor: palette.gray
  },
  title: {
    marginTop: 6,
    fontSize: 16
  },
  leftNavButtonText: {
    fontSize: 18,
    marginLeft: 13,
    marginTop: 4
  },
  rightNavButtonText: {
    fontSize: 18,
    marginRight: 13,
    marginTop: 4
  }
});

console.ignoredYellowBox = [
  'Warning: Failed propType',
  'Warning: ScrollView'
];

AppRegistry.registerComponent('SCExampleApp', () => SCExampleApp);
