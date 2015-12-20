var path = require('path');

module.exports = {
  entry : {
    app : './app/App',
    test : './test/spec/index.spec'
  },
  output : {
    path : __dirname,
    filename : '[name].bundle.js'
  },
  module:{
    loaders:[
      {
        test:/\.jsx?$/,
        exclude:/(node_modules|bower_components)/,
        loader:'babel'
      },
      {
        test:/\.css$/,
        exclude:/(node_modules|bower_components)/,
        loader: 'style!css'
      },
      {
        test:/\.png$/,
        exclude:/(node_modules|bower_components)/,
        loader: 'url'
      }
    ]
  }
};
