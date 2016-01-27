module.exports = {
  entry : './app/App.js',
  output : {
    filename : 'bundle.js'
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
